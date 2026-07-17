import Foundation
import AtlasCore

// Spoken effort names — peel de ConversationChrome+ComposerSheets+A11yEffort.

extension ComposerSheetA11y {
    static func spokenEffort(_ effort: AtlasComputeEffort) -> String {
        switch effort {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        }
    }
}
