import Foundation
import CryptoKit
import AtlasCore

private actor LongMessageUploadTransport: UploadTransport {
    private var started: [ChunkStartRequest] = []
    private var chunks: [ChunkPartRequest] = []

    func start(_ request: ChunkStartRequest) async throws -> ChunkStartResponse {
        started.append(request)
        return try decode(ChunkStartResponse.self, """
        {"upload":{"id":"upload-long","received_chunks":[]}}
        """)
    }

    func sendChunk(uploadId: String, _ body: ChunkPartRequest) async throws -> ChunkPartResponse {
        chunks.append(body)
        return try decode(ChunkPartResponse.self, """
        {"upload":{"id":"upload-long","received_chunks":[0]}}
        """)
    }

    func complete(uploadId: String) async throws -> ChunkCompleteResponse {
        let bytes = chunks.sorted { $0.index < $1.index }.compactMap {
            Data(base64Encoded: $0.chunkBase64)
        }.reduce(into: Data()) { $0.append($1) }
        let sha = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
        return try decode(ChunkCompleteResponse.self, """
        {"upload":{"id":"upload-long","sha256":"\(sha)","bytes":\(bytes.count)}}
        """)
    }

    func startRequests() -> [ChunkStartRequest] { started }
}

public func runLongMessageChecks(_ check: (String, Bool) -> Void) async {
    print("\nRich Input · mensagem longa C4:")

    let boundary = String(repeating: "a", count: 40_000)
    let untouched = try? AtlasLongMessage.prepare(boundary)
    check("40k exatos permanecem inline", untouched?.transformed == false)
    check("inline preserva input byte a byte", untouched?.inputText == boundary)

    let original = "# Pedido importante\n\n" + String(repeating: "conteúdo detalhado. ", count: 2_300)
    let prepared = try? AtlasLongMessage.prepare(
        original,
        now: Date(timeIntervalSince1970: 1_725_000_000),
        nonce: "golden"
    )
    check("texto >40k é externalizado", prepared?.transformed == true)
    check("prompt compacto fica abaixo do limiar", (prepared?.inputText.utf16.count ?? .max) < 40_000)
    check("gera exatamente um anexo Markdown", prepared?.attachment?.mimeType == "text/markdown")
    check("anexo usa origem long_message", prepared?.attachment?.source == "long_message")
    check("metadata segue atlas.long_message.v1", prepared?.metadata?["schema"]?.stringValue == "atlas.long_message.v1")
    check("metadata registra tamanho original", prepared?.metadata?["original_chars"]?.doubleValue == Double(original.utf16.count))

    let artifactData = try? prepared?.attachment?.bytes.read(
        offset: 0,
        length: prepared?.attachment?.bytes.totalBytes ?? 0
    )
    let artifact = artifactData.flatMap { String(data: $0, encoding: .utf8) }
    let marker = "## Conteúdo original\n\n"
    let exactBody = artifact?.components(separatedBy: marker).last
    check("artefato preserva conteúdo integral uma vez", exactBody == original + "\n")

    let transport = LongMessageUploadTransport()
    let engine = AtlasRichInputEngine(
        transport: transport,
        retry: RetryPolicy(attempts: 1, baseDelayMs: 0),
        installSalt: "checks"
    )
    if let attachment = prepared?.attachment {
        do {
            let uploaded = try await engine.uploadAll(images: [], documents: [attachment])
            let fields = engine.interactionFields(
                images: [], documents: uploaded.documents, inputText: prepared?.inputText ?? ""
            )
            check("wire anexa Markdown uma única vez", fields.uploadedDocuments == ["upload-long"])
            check("manifest registra um único documento", fields.richInputPayload?.uploadedDocumentIds == ["upload-long"])
            check("upload usa kind file", await transport.startRequests().first?.kind == "file")
        } catch {
            check("long-message percorre engine real", false)
        }
    } else {
        check("long-message produziu attachment para engine", false)
    }

    do {
        _ = try AtlasLongMessage.prepare(original, existingTextFileCount: AtlasAttachmentLimits.canonical.maxTextFiles)
        check("limite de anexos bloqueia externalização", false)
    } catch AtlasLongMessageError.attachmentLimitReached {
        check("limite de anexos bloqueia externalização", true)
    } catch {
        check("limite retorna erro tipado correto", false)
    }
}

public func runLongMessageLiveProbe(
    _ check: (String, Bool) -> Void,
    client: AtlasClient
) async {
    print("\nRich Input · mensagem longa AO VIVO (C4):")
    let canary = "ATLAS-C4-CANARY"
    let original = "Leia o documento completo e responda somente com o marcador da última linha.\n\n"
        + String(repeating: "contexto neutro para provar transporte integral. ", count: 1_050)
        + "\n\n\(canary)"
    do {
        let prepared = try AtlasLongMessage.prepare(original, nonce: "live")
        guard let attachment = prepared.attachment else {
            check("live C4 preparou Markdown", false)
            return
        }
        let engine = AtlasRichInputEngine(transport: client, installSalt: "c4-live-probe")
        let uploaded = try await engine.uploadAll(images: [], documents: [attachment])
        let fields = engine.interactionFields(
            images: [], documents: uploaded.documents, inputText: prepared.inputText
        )
        var payload = atlasMobileInteractionPayload(base: JSONObject([
            "tool_permissions": .object(["mode": .string("read")]),
        ]))
        if let metadata = prepared.metadata {
            payload.values["long_message"] = .object(metadata.values)
        }
        let input = CreateAiInteractionInput(
            inputText: prepared.inputText,
            clientId: UUID().uuidString.lowercased(),
            newThread: true,
            sourceType: "app",
            payload: payload,
            uploadedDocuments: fields.uploadedDocuments,
            richInputPayload: fields.richInputPayload
        )
        let outboxURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("atlas-c4-live-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: outboxURL) }
        let run = InteractionRun(
            transport: client,
            outbox: InteractionOutbox(fileURL: outboxURL)
        )
        var finalTrace: AtlasAiTrace?
        for try await event in await run.start(input: input) {
            if case .completed(_, let trace) = event { finalTrace = trace }
        }
        check("live C4 create anexou um único Markdown", fields.uploadedDocuments.count == 1)
        check("live C4 input_text ficou compacto", prepared.inputText.utf16.count < AtlasLongMessage.artifactThresholdUTF16)
        check("live provider leu conteúdo fora do prompt compacto",
              finalTrace?.responseText?.contains(canary) == true)
    } catch {
        check("live C4 upload → create → provider", false)
        print("    erro: \(error)")
    }
}

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(type, from: Data(json.utf8))
}
