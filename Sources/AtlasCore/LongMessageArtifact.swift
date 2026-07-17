import Foundation

extension AtlasLongMessage {
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
