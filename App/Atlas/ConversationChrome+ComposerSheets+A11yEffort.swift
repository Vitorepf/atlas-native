import Foundation
import AtlasCore

// Effort spoken — peel de ComposerSheetA11y.
// Spoken → ConversationChrome+ComposerSheets+A11yEffortSpoken.swift
// Subtitle → ConversationChrome+ComposerSheets+A11yEffortSubtitle.swift

extension ComposerSheetA11y {
    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenEffort(effort)), \(state)"
    }
}
