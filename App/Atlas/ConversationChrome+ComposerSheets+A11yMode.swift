import Foundation
import AtlasCore

// Mode spoken — peel de ConversationChrome+ComposerSheets+A11y.
// Workspace → ConversationChrome+ComposerSheets+A11yWorkspace.swift
// Hints → ConversationChrome+ComposerSheets+A11yHints.swift

extension ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }
}
