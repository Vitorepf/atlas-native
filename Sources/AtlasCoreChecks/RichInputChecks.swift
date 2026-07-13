import Foundation
import AtlasCore

// Golden checks do Rich Input L1 — comparados contra a fixture GERADA PELO
// CANON TS (packages/atlas-rich-input-canon/fixtures/rich-input.json, via
// `npx tsx scripts/export-fixtures.ts`). É o pino bidirecional anti-drift:
// se o canon mudar, o TS e o Swift quebram JUNTOS.
//
// A fixture é OBRIGATÓRIA (fail loudly, não skip): sem ela o Swift vira o
// terceiro runtime divergente — exatamente a doença que a migração cura.

struct RIFixture: Decodable {
    struct Limits: Decodable {
        let maxImages, maxPdfs, maxTextFiles, maxUrls: Int
        let maxImageBytes, maxPdfBytes, maxTextBytes, maxTextPreviewChars, maxImageDimension: Int
        let imageJpegQuality, imageWebpQuality: Double
        let chunkSize: Int
    }
    struct Attachment: Decodable {
        let id: String?, uri: String?
        let fileName: String, mimeType: String
        let size: Int?, source: String?
    }
    struct PayloadInput: Decodable {
        let imageAttachments: [Attachment]
        let uploadedImageIds: [String]
        let fileAttachments: [Attachment]
        let uploadedDocumentIds: [String]
        let inputText: String?
    }
    struct PayloadCase: Decodable { let input: PayloadInput; let expected: JSONValue }
    struct Classified: Decodable { let url: String; let kind: String; let refId: String? }
    struct UrlCase: Decodable {
        let url: String; let classified: Classified; let normalizedYoutube: String?
        enum CodingKeys: String, CodingKey { case url, classified, normalizedYoutube = "normalized_youtube" }
    }
    struct Detected: Decodable { let kind: String; let language: String?; let reason: String }
    struct KindCase: Decodable { let mime: String; let name: String; let detected: Detected }
    struct FnvCase: Decodable { let input: String; let hash36: String }
    struct ChunkCase: Decodable {
        let totalBytes: Int; let chunkCount: Int; let lastChunkBytes: Int
        enum CodingKeys: String, CodingKey {
            case totalBytes = "total_bytes", chunkCount = "chunk_count", lastChunkBytes = "last_chunk_bytes"
        }
    }
    let limits: Limits
    let payloadCase: PayloadCase
    let urlCases: [UrlCase]
    let kindCases: [KindCase]
    let fnvCases: [FnvCase]
    let chunkCases: [ChunkCase]
    enum CodingKeys: String, CodingKey {
        case limits, payloadCase = "payload_case", urlCases = "url_cases"
        case kindCases = "kind_cases", fnvCases = "fnv_cases", chunkCases = "chunk_cases"
    }
}

func loadRichInputFixture() -> RIFixture? {
    let candidates = [
        ProcessInfo.processInfo.environment["ATLAS_FIXTURES"],
        "../packages/atlas-rich-input-canon/fixtures/rich-input.json",
        "/Users/vitorepf/develop/Atlas/packages/atlas-rich-input-canon/fixtures/rich-input.json",
    ].compactMap { $0 }
    for path in candidates {
        guard let data = FileManager.default.contents(atPath: path) else { continue }
        return try? JSONDecoder().decode(RIFixture.self, from: data)
    }
    return nil
}

func runRichInputChecks(_ check: (String, Bool) -> Void) {
    print("\nRich Input L1 (fixture canônica TS ↔ Swift — anti-drift):")
    guard let fx = loadRichInputFixture() else {
        check("fixture rich-input.json encontrada e decodável (regenerar: npx tsx scripts/export-fixtures.ts no canon)", false)
        return
    }

    // Limites pinados — Swift ↔ canon ↔ validators do servidor
    let l = AtlasAttachmentLimits.canonical
    check("limites idênticos ao canon (8/4/8/16 · 20MB · 4MB · chunk 1.5MB)",
          l.maxImages == fx.limits.maxImages && l.maxPdfs == fx.limits.maxPdfs
          && l.maxTextFiles == fx.limits.maxTextFiles && l.maxUrls == fx.limits.maxUrls
          && l.maxImageBytes == fx.limits.maxImageBytes && l.maxPdfBytes == fx.limits.maxPdfBytes
          && l.maxTextBytes == fx.limits.maxTextBytes && l.maxTextPreviewChars == fx.limits.maxTextPreviewChars
          && l.maxImageDimension == fx.limits.maxImageDimension && l.chunkBytes == fx.limits.chunkSize
          && abs(l.imageJpegQuality - fx.limits.imageJpegQuality) < 0.0001)

    // FNV-1a 32-bit bit-igual ao Math.imul/charCodeAt do JS (inclui não-ASCII)
    for c in fx.fnvCases {
        check("fnv36(\(c.input.isEmpty ? "<vazio>" : String(c.input.prefix(28))))",
              atlasFnv36(c.input) == c.hash36)
    }

    // classifyUrl + normalizeYouTubeUrl idênticos
    for c in fx.urlCases {
        let d = AtlasURLDetector.classify(c.url)
        check("classify \(c.url.prefix(44))",
              d.kind == c.classified.kind && d.refId == c.classified.refId && d.url == c.classified.url)
        check("normalizeYT \(c.url.prefix(40))",
              AtlasURLDetector.normalizeYouTubeUrl(c.url) == c.normalizedYoutube)
    }

    // detectAttachmentKind idêntico (kind + language + reason)
    for c in fx.kindCases {
        let d = AtlasAttachmentClassifier.detect(mimeType: c.mime, fileName: c.name)
        check("kind \(c.name) [\(c.mime.isEmpty ? "sem-mime" : c.mime)] → \(c.detected.kind)",
              d.kind.rawValue == c.detected.kind && d.language == c.detected.language
              && d.reason == c.detected.reason)
    }

    // O CHECK-REI: payload construído pelo builder Swift ≡ payload construído
    // pelo buildRichInputPayload do TS (comparação estrutural via JSONValue —
    // ordem de chave é livre, valores e nulls explícitos têm que bater).
    do {
        let input = fx.payloadCase.input
        func src(_ a: RIFixture.Attachment) -> RichInputManifestSource {
            .init(id: a.id, uri: a.uri, fileName: a.fileName, mimeType: a.mimeType,
                  size: a.size, source: a.source)
        }
        let built = RichInputPayloadBuilder.build(
            imageAttachments: input.imageAttachments.map(src),
            uploadedImageIds: input.uploadedImageIds,
            fileAttachments: input.fileAttachments.map(src),
            uploadedDocumentIds: input.uploadedDocumentIds,
            inputText: input.inputText ?? "")
        let encoded = try JSONEncoder().encode(built)
        let builtValue = try JSONDecoder().decode(JSONValue.self, from: encoded)
        check("payload v1 Swift ≡ payload v1 do canon TS (fixture, estrutural)",
              builtValue == fx.payloadCase.expected)
        if builtValue != fx.payloadCase.expected {
            print("    swift: \(String(data: encoded, encoding: .utf8) ?? "?")")
        }
    } catch {
        check("payload v1 encode/compare sem erro", false)
        print("    erro: \(error)")
    }

    // Regra compact única (manifest sozinho NÃO conta como anexo)
    let onlyManifest = AtlasRichInputPayload(
        sourceManifest: [.init(id: "x", kind: .image, fileName: "a.png", mimeType: "image/png",
                               size: 1, uploadedId: nil, sourceHash: nil, source: "app")])
    check("compact: manifest sozinho → nil", RichInputPayloadBuilder.compact(onlyManifest) == nil)
    let withUrl = AtlasRichInputPayload(urlAttachments: [.init(url: "https://x.dev", kind: "generic")])
    check("compact: 1 url → payload vive", RichInputPayloadBuilder.compact(withUrl) != nil)
}
