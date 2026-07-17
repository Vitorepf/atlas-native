import Foundation
import AtlasCore

// Snippet/row spoken — peel de ConversationChromeSheets+Outline+A11y.

enum ConversationOutlineA11ySnippet {
    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(ConversationOutlineA11y.spokenRole(role)), \(snippet)"
    }
}
