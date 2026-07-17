import Foundation

public enum AtlasLongMessageError: Error, CustomStringConvertible, Sendable {
    case attachmentLimitReached(maximum: Int)
    case artifactTooLarge(bytes: Int, maximum: Int)

    public var description: String {
        switch self {
        case .attachmentLimitReached(let maximum):
            return "mensagem longa precisa de 1 anexo Markdown; limite de \(maximum) arquivos atingido"
        case .artifactTooLarge(let bytes, let maximum):
            return "mensagem longa gera \(bytes) bytes; máximo permitido é \(maximum)"
        }
    }
}

public struct AtlasPreparedLongMessage: Sendable {
    public let inputText: String
    public let attachment: AttachmentInput?
    public let metadata: JSONObject?
    public let transformed: Bool
}

/// Externalização canônica de mensagens grandes. A interface esconde chunking,
/// resumo, artifact Markdown e metadata; callers só combinam o AttachmentInput
/// retornado com os demais documentos do engine único.
public enum AtlasLongMessage {
    public static let artifactThresholdUTF16 = 40_000
    public static let chunkUTF16 = 6_000
    public static let topChunkCount = 5

    public static func prepare(
        _ input: String,
        existingTextFileCount: Int = 0,
        now: Date = Date(),
        nonce: String? = nil,
        limits: AtlasAttachmentLimits = .canonical
    ) throws -> AtlasPreparedLongMessage {
        let originalChars = input.utf16.count
        guard originalChars > artifactThresholdUTF16 else {
            return AtlasPreparedLongMessage(
                inputText: input, attachment: nil, metadata: nil, transformed: false
            )
        }
        guard existingTextFileCount < limits.maxTextFiles else {
            throw AtlasLongMessageError.attachmentLimitReached(maximum: limits.maxTextFiles)
        }

        let chunks = chunks(for: input)
        let summary = structuralSummary(input: input, chunks: chunks)
        let priority = chunks.sorted {
            $0.score == $1.score ? $0.index < $1.index : $0.score > $1.score
        }.prefix(topChunkCount).sorted { $0.index < $1.index }
        let fileName = artifactFileName(now: now, nonce: nonce)
        let artifact = artifactBody(
            input: input, now: now, originalChars: originalChars,
            chunks: chunks, summary: summary, priority: Array(priority)
        )
        let data = Data(artifact.utf8)
        guard data.count <= limits.maxTextBytes else {
            throw AtlasLongMessageError.artifactTooLarge(bytes: data.count, maximum: limits.maxTextBytes)
        }

        let compact = compactPrompt(fileName: fileName, summary: summary, priority: Array(priority))
        let identityHash = atlasFnv36(input)
        let attachment = AtlasAttachmentAdapter.data(
            data,
            fileName: fileName,
            mimeType: "text/markdown",
            source: "long_message",
            identity: "long-message:\(identityHash)"
        )
        let metadata = JSONObject([
            "schema": .string("atlas.long_message.v1"),
            "original_chars": .number(Double(originalChars)),
            "artifact_name": .string(fileName),
            "artifact_bytes": .number(Double(data.count)),
            "chunk_count": .number(Double(chunks.count)),
            "compact_input_chars": .number(Double(compact.utf16.count)),
            "priority_chunk_indexes": .array(priority.map { .number(Double($0.index)) }),
        ])
        return AtlasPreparedLongMessage(
            inputText: compact, attachment: attachment,
            metadata: metadata, transformed: true
        )
    }
}
