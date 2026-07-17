import Foundation
import AtlasCore

// Spoken effort names — peel de ConversationChrome+ComposerSheets+A11yEffort.
// Light → ConversationChrome+ComposerSheets+A11yEffortSpoken+Light.swift

extension ComposerSheetA11y {
    static func spokenEffort(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLight(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático"
        }
    }
}
