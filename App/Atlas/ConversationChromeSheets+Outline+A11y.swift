import Foundation
import AtlasCore

/// Spoken labels do índice — peel de ConversationChromeSheets+Outline (CICLO C).
/// Snippet → ConversationChromeSheets+Outline+A11ySnippet.swift
/// Role → ConversationChromeSheets+Outline+A11yRole.swift

enum ConversationOutlineA11y {
    static func spokenSheetLabel(turnCount: Int) -> String {
        guard turnCount > 0 else { return spokenEmptySheet() }
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }
}
