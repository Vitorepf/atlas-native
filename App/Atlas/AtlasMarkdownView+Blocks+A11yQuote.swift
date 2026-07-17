import Foundation

/// Quote spoken — peel de AtlasMarkdownView+Blocks+A11y.

enum MarkdownBlocksA11yQuote {
    static func spokenQuote(_ plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "citação vazia" : "citação, \(trimmed)"
    }
}
