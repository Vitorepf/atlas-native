import Foundation
import AtlasCore
import CryptoKit

// Fronteiras enforced por check (análogo Swift do anti-regression scan do
// desktop): a doença dos dois chunkedUploaders TS não pode nascer aqui.
//   1. AtlasCore não importa UIKit/AppKit/SwiftUI/PhotosUI (Foundation-only).
//   2. Nenhum código do APP fala com /ai/uploads/* direto — só via engine.
//   3. A casca é apresentação: zero rede, JSON ou storage. Esses efeitos vivem
//      nos dois owners explícitos (models) ou no Core e chegam por seams tipados.

func runRichInputBoundaryChecks(_ check: (String, Bool) -> Void) {
    print("\nRich Input · fronteiras (o segundo uploader não pode nascer):")
    let fm = FileManager.default

    func swiftFiles(_ dir: String) -> [String] {
        guard let names = try? fm.contentsOfDirectory(atPath: dir) else { return [] }
        return names.filter { $0.hasSuffix(".swift") }.map { dir + "/" + $0 }
    }

    let coreFiles = swiftFiles("Sources/AtlasCore")
    check("Sources/AtlasCore visível do cwd (rode da raiz do repo)", !coreFiles.isEmpty)

    var coreViolations: [String] = []
    for f in coreFiles {
        guard let s = try? String(contentsOfFile: f, encoding: .utf8) else { continue }
        for banned in ["import UIKit", "import AppKit", "import SwiftUI", "import PhotosUI"] {
            if s.contains(banned) { coreViolations.append("\((f as NSString).lastPathComponent): \(banned)") }
        }
    }
    check("AtlasCore é Foundation-only (sem UIKit/AppKit/SwiftUI/PhotosUI)", coreViolations.isEmpty)
    for v in coreViolations { print("    ✗ \(v)") }

    let appFiles = swiftFiles("App/Atlas")
    var appViolations: [String] = []
    for f in appFiles {
        guard let s = try? String(contentsOfFile: f, encoding: .utf8) else { continue }
        if s.contains("/ai/uploads") { appViolations.append((f as NSString).lastPathComponent) }
    }
    check("app não fala com /ai/uploads/* direto (só via AtlasRichInputEngine)", appViolations.isEmpty)
    for v in appViolations { print("    ✗ \(v)") }

    let presentationFiles = appFiles.filter {
        let name = ($0 as NSString).lastPathComponent
        return name != "ConversationModel.swift" && name != "AtlasSession.swift"
    }
    let forbiddenViewEffects = [
        "URLSession", "URLRequest", "JSONDecoder", "JSONEncoder", "JSONSerialization",
        "UserDefaults", "@AppStorage", "FileManager", "/ai/", "http://", "https://",
    ]
    var presentationViolations: [String] = []
    for file in presentationFiles {
        guard let source = try? String(contentsOfFile: file, encoding: .utf8) else { continue }
        for token in forbiddenViewEffects where source.contains(token) {
            presentationViolations.append("\((file as NSString).lastPathComponent): \(token)")
        }
    }
    check("casca não faz rede, JSON ou storage", presentationViolations.isEmpty)
    for violation in presentationViolations { print("    ✗ \(violation)") }

    let conversationModel = try? String(
        contentsOfFile: "App/Atlas/ConversationModel.swift",
        encoding: .utf8
    )
    check("model prepara imagens fora da MainActor",
          conversationModel?.contains("AtlasImaging.normalize(") == false
          && conversationModel?.contains("AtlasImaging.prepareForComposer(") == true)
    check("envio aguarda imagens ainda em preparação",
          conversationModel?.contains("await finishPendingImagePreparations()") == true)
}

// Live-probe (opt-in: ATLAS_LIVE=1 + ATLAS_TOKEN) — sobe 3.2MB REAIS pro
// atlas-server, confere o sha256 do complete contra o local e prova o resume
// re-startando com a mesma chave. Só staging: NÃO cria interação (não polui
// as threads do operador). Gate recomendado do `make device`.
func runRichInputLiveProbe(_ check: (String, Bool) -> Void, client: AtlasClient) async {
    print("\nRich Input · LIVE-PROBE (atlas-server real, só staging):")
    var payload = Data(count: 3_355_443)  // ~3.2MB → 3 chunks
    payload.withUnsafeMutableBytes { buf in
        for i in 0..<buf.count { buf[i] = UInt8((i &* 131) & 0xff) }
    }
    let salt = "liveprobe-\(ProcessInfo.processInfo.processIdentifier)"
    let engine = AtlasRichInputEngine(transport: client, installSalt: salt)
    do {
        let adapted = AtlasAttachmentAdapter.data(
            payload, fileName: "liveprobe.png", mimeType: "image/png",
            source: "camera", identity: "liveprobe"
        )
        let asset = try await engine.upload(adapted)
        let localSha = SHA256.hash(data: payload).map { String(format: "%02x", $0) }.joined()
        check("upload 3.2MB real: sha256 do servidor == local", asset.sha256 == localSha)
        let fields = engine.interactionFields(images: [asset], documents: [], inputText: "analise")
        check("adapter câmera produz payload real do create",
              fields.uploadedImages == [asset.uploadedId] &&
              fields.richInputPayload?.sourceManifest.first?.source == "camera")

        // Resume real: re-start com a MESMA chave → received_chunks completo
        let key = atlasStableUploadKey(identity: "liveprobe", fileName: "liveprobe.png",
                                       bytes: payload.count, installSalt: salt)
        let restart = try await client.start(ChunkStartRequest(
            clientUploadId: key, kind: "image", fileName: "liveprobe.png",
            mimeType: "image/png", totalBytes: payload.count, source: "app"))
        let received = Set(restart.upload.receivedChunks ?? [])
        check("resume real: re-start devolve os 3 chunks já recebidos", received == [0, 1, 2])
    } catch {
        check("live-probe de upload sem erro", false)
        print("    erro: \(error)")
    }
}
