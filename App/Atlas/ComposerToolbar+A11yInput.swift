import SwiftUI
import AtlasCore

// Effort/options spoken — peel de ComposerToolbar+A11y.
// Input field → ComposerToolbar+A11yInputField.swift

extension ComposerToolbar {
    func spokenEffortLabel(_ effort: AtlasComputeEffort) -> String {
        switch effort {
        case .auto: return "esforço automático, Atlas Decide escolhe"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        }
    }

    func spokenEffortHint() -> String {
        "abre opções de esforço computacional para o próximo envio"
    }

    func spokenOptionsHint() -> String {
        "modo, esforço e workspace; \(spokenSendHint(canSubmit: false).lowercased())"
    }
}
