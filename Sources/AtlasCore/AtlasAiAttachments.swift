import Foundation

// Anexos do Atlas AI, portados de lib/api/atlasAi.ts: o objeto de anexo
// (imagem/arquivo, com status de processamento PDF/office e páginas de preview)
// e a busca semântica em anexos (`searchAiAttachments`). O decoder usa
// `.convertFromSnakeCase`, então snake_case do servidor vira camelCase sem
// CodingKeys. Todo campo que o servidor pode omitir/mandar `null` é opcional.

/// Uma página renderizada de preview de um anexo (`preview_pages[]` no .ts).
public struct AtlasAiAttachmentPreviewPage: Codable, Sendable {
    public let page: Int
    public let url: String
}

public struct AtlasAiAttachment: Codable, Sendable, Identifiable {
    public let id: String
    /// União aberta 'image' | 'file' | string — String pra não quebrar decode.
    public let kind: String
    public let name: String
    public let mimeType: String?
    public let bytes: Int?
    public let sha256: String?
    public let source: String?
    public let textAvailable: Bool?
    public let textTruncated: Bool?
    public let pdfPageCount: Int?
    public let pdfProcessingStatus: String?
    public let pdfChunkCount: Int?
    public let pdfRenderStatus: String?
    public let pdfRenderedPageCount: Int?
    public let pdfOcrStatus: String?
    public let pdfVisualUnderstandingStatus: String?
    public let officeProcessingStatus: String?
    public let officeRenderStatus: String?
    public let officeRenderedPageCount: Int?
    public let contentUrl: String?
    public let previewPages: [AtlasAiAttachmentPreviewPage]?
}

public struct AtlasAiAttachmentSearchResult: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let threadId: String?
    public let attachmentId: String
    public let attachmentKind: String
    public let sourceName: String?
    public let mimeType: String?
    public let unitType: String
    public let unitNumber: Int?
    public let title: String?
    public let excerpt: String
    public let visualCaption: String?
    public let metadata: JSONObject?
    public let indexedAt: String?
    public let score: Double?
}

public struct AtlasAiAttachmentSearchResponse: Codable, Sendable {
    public let results: [AtlasAiAttachmentSearchResult]
}

/// Corpo de `searchAiAttachments` — o encoder faz `.convertToSnakeCase`
/// (threadId → thread_id).
public struct SearchAiAttachmentsInput: Encodable, Sendable {
    public var query: String
    public var threadId: String?
    public var limit: Int?

    public init(query: String, threadId: String? = nil, limit: Int? = nil) {
        self.query = query
        self.threadId = threadId
        self.limit = limit
    }
}

// MARK: - Client

public extension AtlasClient {
    /// POST /ai/attachments/search — busca semântica em anexos (mirror de
    /// `searchAiAttachments`).
    func searchAiAttachments(_ input: SearchAiAttachmentsInput) async throws -> AtlasAiAttachmentSearchResponse {
        try await post("/ai/attachments/search", body: input)
    }
}

// MARK: - Golden checks

public func runAttachmentsChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "results": [
        {
          "id": "res_1",
          "trace_id": "trace_abc",
          "thread_id": null,
          "attachment_id": "att_9",
          "attachment_kind": "file",
          "source_name": "spec.pdf",
          "mime_type": "application/pdf",
          "unit_type": "page",
          "unit_number": 3,
          "title": null,
          "excerpt": "the quick brown fox",
          "visual_caption": "a diagram",
          "metadata": { "page_label": "iii", "confidence": 0.82 },
          "indexed_at": "2026-07-01T12:00:00Z",
          "score": 0.91
        }
      ]
    }
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    do {
        let resp = try decoder.decode(AtlasAiAttachmentSearchResponse.self, from: Data(json.utf8))
        let first = resp.results.first
        check("attachments: results decoded", resp.results.count == 1)
        check("attachments: snake->camel (trace_id/attachment_id)",
              first?.traceId == "trace_abc" && first?.attachmentId == "att_9")
        check("attachments: Int unit_number", first?.unitNumber == 3)
        check("attachments: Double score", first?.score == 0.91)
        check("attachments: JSONValue metadata bag",
              first?.metadata?["page_label"]?.stringValue == "iii")
        check("attachments: null->nil optional", first?.title == nil && first?.threadId == nil)
    } catch {
        check("attachments: decode fixture", false)
    }
}
