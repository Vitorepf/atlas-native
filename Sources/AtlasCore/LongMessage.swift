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

private extension AtlasLongMessage {
    struct Chunk: Sendable {
        let index: Int
        let start: Int
        let end: Int
        let text: String
        let preview: String
        let score: Int
    }

    static func chunks(for input: String) -> [Chunk] {
        let normalized = input.replacingOccurrences(of: "\r\n", with: "\n")
        let blocks = paragraphBlocks(normalized)
        var texts: [(text: String, start: Int)] = []
        var current = ""
        var currentStart = 0
        var cursor = 0

        func flush() {
            let text = current.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            texts.append((text, currentStart))
            current = ""
            currentStart = cursor
        }

        for block in blocks.isEmpty ? [normalized] : blocks {
            let blockLength = block.utf16.count
            let joined = current.isEmpty ? block : current + "\n\n" + block
            if !current.isEmpty, joined.utf16.count > chunkUTF16 { flush() }

            if blockLength > chunkUTF16 {
                for slice in splitByUTF16(block, maximum: chunkUTF16) {
                    current = slice
                    currentStart = cursor
                    flush()
                    cursor += slice.utf16.count
                }
                cursor += 2
                currentStart = cursor
                continue
            }

            if current.isEmpty { currentStart = cursor }
            current = current.isEmpty ? block : current + "\n\n" + block
            cursor += blockLength + 2
        }
        flush()
        if texts.isEmpty { texts = [(input, 0)] }

        return texts.enumerated().map { offset, value in
            let provisional = Chunk(
                index: offset + 1,
                start: value.start,
                end: value.start + value.text.utf16.count,
                text: value.text,
                preview: compactPreview(value.text, maximum: 420),
                score: 0
            )
            return Chunk(
                index: provisional.index, start: provisional.start, end: provisional.end,
                text: provisional.text, preview: provisional.preview,
                score: score(provisional)
            )
        }
    }

    static func paragraphBlocks(_ input: String) -> [String] {
        var blocks: [String] = []
        var lines: [Substring] = []
        func flush() {
            let block = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !block.isEmpty { blocks.append(block) }
            lines.removeAll(keepingCapacity: true)
        }
        for line in input.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { flush() }
            else { lines.append(line) }
        }
        flush()
        return blocks
    }

    static func splitByUTF16(_ text: String, maximum: Int) -> [String] {
        guard maximum > 0 else { return [text] }
        var result: [String] = []
        var start = text.startIndex
        var cursor = start
        var units = 0
        while cursor < text.endIndex {
            let next = text.index(after: cursor)
            let size = text[cursor..<next].utf16.count
            if units > 0, units + size > maximum {
                result.append(String(text[start..<cursor]))
                start = cursor
                units = 0
            }
            units += size
            cursor = next
        }
        if start < text.endIndex { result.append(String(text[start..<text.endIndex])) }
        return result
    }

    static func structuralSummary(input: String, chunks: [Chunk]) -> [String] {
        let normalized = input.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.split(separator: "\n").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        let headings = lines.filter { line in
            let hashes = line.prefix { $0 == "#" }.count
            if (1...4).contains(hashes), line.dropFirst(hashes).first == " " { return true }
            return line.count <= 81 && line.last == ":" && line.first?.isUppercase == true
        }.prefix(8).map { line in
            String(line.drop { $0 == "#" || $0 == " " })
        }
        let questions = normalized.filter { $0 == "?" }.count
        let bullets = lines.filter { line in
            line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("• ")
                || line.first?.isNumber == true && (line.contains(". ") || line.contains(") "))
        }.count
        let fences = normalized.components(separatedBy: "```").count - 1
        var summary = [
            "\(input.utf16.count) caracteres preservados integralmente em \(chunks.count) bloco(s).",
            "\(questions) pergunta(s), \(bullets) item(ns) de lista e \(fences / 2) bloco(s) de código detectados.",
        ]
        if let first = lines.first {
            let opening = compactPreview(first, maximum: 160)
            if !opening.isEmpty { summary.append("abertura: \(opening)") }
        }
        if !headings.isEmpty { summary.append("tópicos detectados: \(headings.joined(separator: " | "))") }
        return summary
    }

    static func score(_ chunk: Chunk) -> Int {
        let lower = chunk.text.lowercased()
        var value = chunk.index == 1 ? 40 : 0
        value += min(30, chunk.text.filter { $0 == "?" }.count * 8)
        let terms = ["importante", "preciso", "problema", "erro", "falha", "corrig",
                     "implementar", "decisão", "decisao", "objetivo", "requisito", "pergunta"]
        if terms.contains(where: lower.contains) { value += 24 }
        if chunk.text.split(separator: "\n").contains(where: { $0.hasPrefix("#") }) { value += 16 }
        if chunk.text.contains("```") { value += 12 }
        value += min(12, Int((Double(chunk.text.utf16.count) / 1000).rounded()))
        return value
    }

    static func artifactBody(
        input: String, now: Date, originalChars: Int,
        chunks: [Chunk], summary: [String], priority: [Chunk]
    ) -> String {
        var lines = [
            "---", "schema: atlas.long_message.v1", "created_at: \(iso8601(now))",
            "original_chars: \(originalChars)", "chunks: \(chunks.count)", "---", "",
            "# Mensagem longa enviada ao Atlas", "", "## Resumo estrutural",
        ]
        lines.append(contentsOf: summary.map { "- \($0)" })
        lines += ["", "## Blocos prioritários"]
        lines.append(contentsOf: priority.map {
            "- bloco \($0.index): caracteres \($0.start)-\($0.end); \($0.preview)"
        })
        lines += ["", "## Conteúdo original", "", input, ""]
        return lines.joined(separator: "\n")
    }

    static func compactPrompt(fileName: String, summary: [String], priority: [Chunk]) -> String {
        var lines = [
            "[Mensagem longa preservada como anexo textual: \(fileName)]", "",
            "O conteúdo completo está no anexo Markdown. Leia o anexo quando a resposta depender de detalhes, ordem, nomes, listas ou trechos exatos. Não responda apenas pelo resumo se o pedido exigir precisão.",
            "", "Resumo estrutural:",
        ]
        lines.append(contentsOf: summary.map { "- \($0)" })
        lines += ["", "Trechos prioritários para orientação inicial:"]
        lines.append(contentsOf: priority.map {
            "- bloco \($0.index) (\($0.start)-\($0.end)): \($0.preview)"
        })
        lines += ["", "Pedido: responda considerando o conteúdo completo do anexo."]
        return lines.joined(separator: "\n")
    }

    static func compactPreview(_ value: String, maximum: Int) -> String {
        let compacted = value.split(whereSeparator: \Character.isWhitespace).joined(separator: " ")
        guard compacted.count > maximum else { return compacted }
        return String(compacted.prefix(max(0, maximum - 1))).trimmingCharacters(in: .whitespaces) + "…"
    }

    static func artifactFileName(now: Date, nonce: String?) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: now)
        func pad(_ value: Int?) -> String { String(format: "%02d", value ?? 0) }
        let stamp = "\(components.year ?? 0)\(pad(components.month))\(pad(components.day))-\(pad(components.hour))\(pad(components.minute))\(pad(components.second))"
        let suffix = nonce ?? String(UUID().uuidString.lowercased().prefix(4))
        return "atlas-long-message-\(stamp)-\(suffix).md"
    }

    static func iso8601(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
