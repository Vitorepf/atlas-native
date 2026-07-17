import Foundation
import AtlasCore

/// Spoken labels do índice — peel de ConversationChromeSheets+Outline (CICLO C).
/// Snippet → ConversationChromeSheets+Outline+A11ySnippet.swift

enum ConversationOutlineA11y {
    static func spokenSheetLabel(turnCount: Int) -> String {
        guard turnCount > 0 else { return spokenEmptySheet() }
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }

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
