import Foundation
import AtlasCore

// Effort spoken — peel de ComposerSheetA11y.

extension ComposerSheetA11y {
    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenEffort(effort)), \(state)"
    }

    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        }
    }

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
