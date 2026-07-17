import Foundation
import AtlasCore

/// Outline role helpers — peel de ConversationChromeSheets+Outline+A11y.

extension ConversationOutlineA11y {
    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }

    static func spokenSnippet(from text: String) -> String {
        ConversationOutlineA11ySnippet.spokenSnippet(from: text)
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        ConversationOutlineA11ySnippet.spokenRow(index: index, role: role, snippet: snippet)
    }
}
