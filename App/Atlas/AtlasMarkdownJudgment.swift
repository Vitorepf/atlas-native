import Foundation

// MARK: - Judgment

/// Pure markdown block spoken grammar (WAVE-103).
/// Casca only — never invents plain text or language labels.
enum AtlasMarkdownJudgment {

    // MARK: List / quote

    static func spokenListItem(ordered: Bool, index: Int, plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ordered ? "item \(index + 1), vazio" : "item, vazio"
        }
        return ordered ? "item \(index + 1), \(trimmed)" : trimmed
    }

    static func spokenQuote(_ plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "citação vazia" : "citação, \(trimmed)"
    }

    // MARK: Code block

    static func spokenBlock(lang: String?, lineCount: Int) -> String {
        var parts = ["bloco de código"]
        if let lang, !lang.isEmpty {
            parts.append("linguagem \(lang.lowercased())")
        } else {
            parts.append("linguagem não informada")
        }
        if lineCount == 0 {
            parts.append("vazio")
        } else {
            parts.append("\(lineCount) linha\(lineCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenCopyButton(copied: Bool, canCopy: Bool) -> String {
        if !canCopy { return "copiar indisponível, bloco vazio" }
        return copied ? "código copiado" : "copiar código"
    }

    static func copyHint(canCopy: Bool) -> String {
        canCopy ? "cola este bloco na área de transferência" : ""
    }

    static func langLabel(lang: String?) -> String? {
        guard let lang, !lang.isEmpty else { return nil }
        return lang.lowercased()
    }

    // MARK: Pack

    static func packFacts(
        hasList: Bool,
        hasQuote: Bool,
        hasCode: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var kinds: [String] = []
        if hasList { kinds.append("list") }
        if hasQuote { kinds.append("quote") }
        if hasCode { kinds.append("code") }
        if kinds.isEmpty {
            absences.append("nenhum bloco estruturado no markdown deste recorte")
        } else {
            facts.append("md_block_kinds: \(kinds.joined(separator: "|"))")
        }
        return (facts, absences)
    }
}
