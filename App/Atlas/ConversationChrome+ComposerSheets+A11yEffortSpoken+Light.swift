import Foundation
import AtlasCore

// Effort auto/fast — peel de ComposerSheets A11yEffortSpoken.

extension ComposerSheetA11y {
    static func spokenEffortLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        default: return nil
        }
    }
}
