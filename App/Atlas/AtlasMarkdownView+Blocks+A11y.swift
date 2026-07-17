import Foundation

/// Spoken helpers de lista/citação — peel de AtlasMarkdownView+Blocks (CICLO C).
/// Marcadores tipográficos são decorativos; VoiceOver lê só o conteúdo.
/// Quote → AtlasMarkdownView+Blocks+A11yQuote.swift

enum MarkdownBlocksA11y {
    static func spokenListItem(ordered: Bool, index: Int, plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ordered ? "item \(index + 1), vazio" : "item, vazio"
        }
        return ordered ? "item \(index + 1), \(trimmed)" : trimmed
    }

    static func spokenQuote(_ plain: String) -> String {
        MarkdownBlocksA11yQuote.spokenQuote(plain)
    }
}
