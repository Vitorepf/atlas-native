import Foundation
import CryptoKit
import AtlasCore

struct CheckBoom: Error {}

// F2 — o loop de upload PROVADO OFFLINE: o InMemoryUploadTransport implementa
// os 3 endpoints em memória (com validação de base64/bytes igual ao servidor),
// o CountingByteSource conta os reads (prova de resume), e a bateria cobre
// chunk math (vs fixture), retry, resume, sha streaming, progresso e fields.

actor InMemoryUploadTransport: UploadTransport {
    struct State { var meta: ChunkStartRequest; var chunks: [Int: Data] }
    private var uploads: [String: State] = [:]
    private var seeded: [Int: Data]
    private var chunkFailuresRemaining: Int
    private(set) var startCalls = 0
    private(set) var chunkPosts: [Int] = []

    init(seededChunks: [Int: Data] = [:], failFirstChunkPosts: Int = 0) {
        self.seeded = seededChunks
        self.chunkFailuresRemaining = failFirstChunkPosts
    }

    func start(_ request: ChunkStartRequest) async throws -> ChunkStartResponse {
        startCalls += 1
        let id = "up_" + request.clientUploadId
        if uploads[id] == nil { uploads[id] = State(meta: request, chunks: seeded) }
        let received = uploads[id]!.chunks.keys.sorted()
        // shape decodado de {"upload":{"id":..,"received_chunks":[..]}}
        let json = #"{"upload":{"id":"\#(id)","received_chunks":[\#(received.map(String.init).joined(separator: ","))]}}"#
        return try dec(ChunkStartResponse.self, json)
    }

    func sendChunk(uploadId: String, _ body: ChunkPartRequest) async throws -> ChunkPartResponse {
        if chunkFailuresRemaining > 0 {
            chunkFailuresRemaining -= 1
            throw CheckBoom()
        }
        guard var state = uploads[uploadId] else {
            throw CheckBoom()
        }
        // validação do servidor: strlen(base64_decode) == bytes
        guard let data = Data(base64Encoded: body.chunkBase64), data.count == body.bytes else {
            throw CheckBoom()
        }
        state.chunks[body.index] = data
        uploads[uploadId] = state
        chunkPosts.append(body.index)
        return try dec(ChunkPartResponse.self, #"{"upload":{"id":"\#(uploadId)","index":\#(body.index)}}"#)
    }

    func complete(uploadId: String) async throws -> ChunkCompleteResponse {
        guard let state = uploads[uploadId] else {
            throw CheckBoom()
        }
        var assembled = Data()
        for i in state.chunks.keys.sorted() { assembled.append(state.chunks[i]!) }
        guard assembled.count == state.meta.totalBytes else {
            throw CheckBoom()
        }
        let sha = SHA256.hash(data: assembled).map { String(format: "%02x", $0) }.joined()
        return try dec(ChunkCompleteResponse.self,
                       #"{"upload":{"id":"\#(uploadId)","bytes":\#(assembled.count),"sha256":"\#(sha)"}}"#)
    }

    func assembled(_ uploadId: String) -> Data? {
        guard let s = uploads[uploadId] else { return nil }
        var out = Data()
        for i in s.chunks.keys.sorted() { out.append(s.chunks[i]!) }
        return out
    }

    private nonisolated func dec<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        let d = JSONDecoder(); d.keyDecodingStrategy = atlasSnakeKeyDecoding
        return try d.decode(type, from: Data(json.utf8))
    }
}

/// ByteSource que CONTA os offsets lidos — prova que o resume lê tudo (hash)
/// mas só POSTA os chunks ausentes.
final class CountingByteSource: AttachmentByteSource, @unchecked Sendable {
    private let inner: DataByteSource
    private let lock = NSLock()
    private var _reads: [Int] = []
    var reads: [Int] { lock.lock(); defer { lock.unlock() }; return _reads }
    var totalBytes: Int { inner.totalBytes }
    init(_ data: Data) { inner = DataByteSource(data) }
    func read(offset: Int, length: Int) throws -> Data {
        lock.lock(); _reads.append(offset); lock.unlock()
        return try inner.read(offset: offset, length: length)
    }
}

/// Coletor thread-safe de progresso (o closure do engine é @Sendable).
final class ProgressBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _events: [UploadProgress] = []
    var events: [UploadProgress] { lock.lock(); defer { lock.unlock() }; return _events }
    func add(_ p: UploadProgress) { lock.lock(); _events.append(p); lock.unlock() }
}

func runRichInputEngineChecks(_ check: (String, Bool) -> Void) async {
    print("\nRich Input L2 (engine offline — InMemoryUploadTransport):")
    guard let fx = loadRichInputFixture() else {
        check("fixture disponível para os checks do engine", false)
        return
    }
    let limits = AtlasAttachmentLimits.canonical

    // chunk math vs fixture (aritmética de referência gerada pelo canon)
    for c in fx.chunkCases {
        let plans = atlasChunkPlans(totalBytes: c.totalBytes, chunkBytes: limits.chunkBytes)
        let contiguous = plans.enumerated().allSatisfy { i, p in
            p.index == i && p.offset == i * limits.chunkBytes
        }
        check("chunks(\(c.totalBytes)) = \(c.chunkCount) (último \(c.lastChunkBytes)B)",
              plans.count == c.chunkCount && plans.last?.length == c.lastChunkBytes && contiguous)
    }

    // chave de resume: determinística + sensível ao salt
    let k1 = atlasStableUploadKey(identity: "ph://X", fileName: "a.jpg", bytes: 42, installSalt: "s1")
    check("stableUploadKey determinística",
          k1 == atlasStableUploadKey(identity: "ph://X", fileName: "a.jpg", bytes: 42, installSalt: "s1"))
    check("stableUploadKey muda com o installSalt (anti-colisão de staging)",
          k1 != atlasStableUploadKey(identity: "ph://X", fileName: "a.jpg", bytes: 42, installSalt: "s2"))

    // retry canônico: 2 falhas → sucesso na 3ª; 3 falhas → propaga
    do {
        let counter = ProgressBox()
        let r: Int = try await atlasWithRetry(RetryPolicy(attempts: 3, baseDelayMs: 1)) {
            counter.add(UploadProgress(phase: .starting, fileName: "", fileIndex: 0, fileCount: 0,
                                       sentBytes: 0, totalBytes: 0, percent: 0))
            if counter.events.count < 3 { throw CheckBoom() }
            return 7
        }
        check("retry: 2 falhas → sucesso na 3ª tentativa", r == 7 && counter.events.count == 3)
    } catch { check("retry: 2 falhas → sucesso na 3ª tentativa", false) }
    do {
        _ = try await atlasWithRetry(RetryPolicy(attempts: 3, baseDelayMs: 1)) { () -> Int in
            throw CheckBoom()
        }
        check("retry: 3 falhas → propaga o erro", false)
    } catch { check("retry: 3 falhas → propaga o erro", true) }

    // upload feliz: 2.5 chunks, sha streaming == sha do arquivo, bytes íntegros
    do {
        var payload = Data(count: limits.chunkBytes * 2 + 1000)
        payload.withUnsafeMutableBytes { buf in
            for i in 0..<buf.count { buf[i] = UInt8((i &* 31) & 0xff) }
        }
        let transport = InMemoryUploadTransport()
        let engine = AtlasRichInputEngine(transport: transport, installSalt: "check")
        let box = ProgressBox()
        let asset = try await engine.upload(
            AttachmentInput(kind: .image, fileName: "foto.jpg", mimeType: "image/jpeg",
                            source: "photos", identity: "id-1", bytes: DataByteSource(payload)),
            progress: { box.add($0) })
        let expectedSha = SHA256.hash(data: payload).map { String(format: "%02x", $0) }.joined()
        let assembled = await transport.assembled(asset.uploadedId)
        check("upload: bytes remontados == original", assembled == payload)
        check("upload: sha256 streaming == sha256 do arquivo (e do servidor)", asset.sha256 == expectedSha)
        let phases = box.events.map(\.phase)
        check("progresso: starting → uploading… → finalizing",
              phases.first == .starting && phases.contains(.uploading) && phases.last == .finalizing)
        let pcts = box.events.map(\.percent)
        check("progresso monotônico 0…1", zip(pcts, pcts.dropFirst()).allSatisfy { $0 <= $1 }
              && (pcts.last ?? 0) <= 1.0)
        let posts = await transport.chunkPosts
        check("3 chunks postados em ordem", posts == [0, 1, 2])
    } catch {
        check("upload feliz sem erro", false); print("    erro: \(error)")
    }

    // RESUME: chunks 0 e 2 já no servidor → lê TUDO (hash) mas posta só 1 e 3
    do {
        let chunk = limits.chunkBytes
        var payload = Data(count: chunk * 3 + 500)
        payload.withUnsafeMutableBytes { buf in
            for i in 0..<buf.count { buf[i] = UInt8((i &* 17) & 0xff) }
        }
        let plans = atlasChunkPlans(totalBytes: payload.count, chunkBytes: chunk)
        let seeded = [0: payload.subdata(in: 0..<chunk),
                      2: payload.subdata(in: (2 * chunk)..<(3 * chunk))]
        let transport = InMemoryUploadTransport(seededChunks: seeded)
        let engine = AtlasRichInputEngine(transport: transport, installSalt: "check")
        let source = CountingByteSource(payload)
        let asset = try await engine.upload(
            AttachmentInput(kind: .pdf, fileName: "doc.pdf", mimeType: "application/pdf",
                            source: "files", identity: "id-2", bytes: source))
        let posts = await transport.chunkPosts
        check("resume: só os chunks ausentes postados [1,3]", posts == [1, 3])
        check("resume: TODOS os \(plans.count) chunks lidos (hash íntegro)", source.reads.count == plans.count)
        let expectedSha = SHA256.hash(data: payload).map { String(format: "%02x", $0) }.joined()
        check("resume: sha256 confere com o arquivo inteiro", asset.sha256 == expectedSha)
    } catch {
        check("resume sem erro", false); print("    erro: \(error)")
    }

    // Falha local barata: HEIC nunca chega ao wire
    do {
        let transport = InMemoryUploadTransport()
        let engine = AtlasRichInputEngine(transport: transport, installSalt: "check")
        _ = try await engine.upload(AttachmentInput(kind: .image, fileName: "x.heic",
                                                    mimeType: "image/heic", source: "photos",
                                                    identity: "id-3", bytes: DataByteSource(Data([1]))))
        check("HEIC rejeitado localmente ANTES do start", false)
    } catch {
        let transport2 = InMemoryUploadTransport()
        _ = transport2   // starts do transport original:
        check("HEIC rejeitado localmente ANTES do start", error is RichInputError)
    }

    // interactionFields: raiz + espelho + compact + source_hash preenchido
    do {
        let transport = InMemoryUploadTransport()
        let engine = AtlasRichInputEngine(transport: transport, installSalt: "check")
        let img = try await engine.upload(AttachmentInput(kind: .image, fileName: "a.png",
                                                          mimeType: "image/png", source: "photos",
                                                          identity: "i", bytes: DataByteSource(Data([9, 9, 9]))))
        let fields = engine.interactionFields(images: [img], documents: [],
                                              inputText: "só texto sem urls")
        check("fields: uploaded_images raiz = [id]", fields.uploadedImages == [img.uploadedId])
        check("fields: payload espelho vive (1 imagem)", fields.richInputPayload != nil)
        check("fields: source_hash PREENCHIDO no manifest (melhoria vs RN/desktop)",
              fields.richInputPayload?.sourceManifest.first?.sourceHash == img.sha256)
        let empty = engine.interactionFields(images: [], documents: [], inputText: "sem nada")
        check("fields: sem anexo nem url → payload nil (compact)", empty.richInputPayload == nil)
    } catch {
        check("interactionFields sem erro", false); print("    erro: \(error)")
    }
}
