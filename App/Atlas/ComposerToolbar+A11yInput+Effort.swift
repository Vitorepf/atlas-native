import SwiftUI
import AtlasCore

// Effort spoken — peel de ComposerToolbar+A11yInput.
// Light → ComposerToolbar+A11yInput+Effort+Light.swift

extension ComposerToolbar {
    func spokenEffortLabel(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLightLabel(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático, Atlas Decide escolhe"
        }
    }
}
