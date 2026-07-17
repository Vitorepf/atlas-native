import SwiftUI
import AtlasCore

// Effort/options spoken — peel de ComposerToolbar+A11y.

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

    func spokenInputLabel() -> String {
        model.bubbles.isEmpty ? "mensagem para o Atlas" : "continuar conversa com o Atlas"
    }

    func spokenInputHint() -> String {
        if canSubmit {
            return isExecuting ? "texto para a fila do próximo turno" : "texto do próximo envio"
        }
        return "escreva aqui para habilitar o envio"
    }
}
