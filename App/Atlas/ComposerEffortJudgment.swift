import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive composer effort face (WAVE-076).
enum ComposerEffortFace: Equatable {
    case auto
    case fast
    case balanced
    case deep
    case max

    var productWord: String {
        switch self {
        case .auto: return "auto"
        case .fast: return "fast"
        case .balanced: return "balanced"
        case .deep: return "deep"
        case .max: return "max"
        }
    }

    /// Toolbar-rich spoken (includes Atlas Decide honesty for auto).
    var spokenToolbar: String {
        switch self {
        case .auto: return "esforço automático, Atlas Decide escolhe"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        }
    }

    /// Sheet list spoken (short product line).
    var spokenSheet: String {
        switch self {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        }
    }

    var subtitle: String {
        switch self {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        }
    }
}

// MARK: - Judgment

/// Pure composer effort grammar — face · spoken · pack.
enum ComposerEffortJudgment {

    static let effortHint = "abre opções de esforço computacional para o próximo envio"
    static let effortSheetHint = "escolhe o esforço computacional do próximo envio"
    static let processingLabel = "Atlas processando"

    static func face(_ effort: AtlasComputeEffort) -> ComposerEffortFace {
        switch effort {
        case .auto: return .auto
        case .fast: return .fast
        case .balanced: return .balanced
        case .deep: return .deep
        case .max: return .max
        }
    }

    static func spokenToolbar(_ effort: AtlasComputeEffort) -> String {
        face(effort).spokenToolbar
    }

    static func spokenSheet(_ effort: AtlasComputeEffort) -> String {
        face(effort).spokenSheet
    }

    static func spokenSheetLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenSheet(effort)), \(state)"
    }

    static func subtitle(_ effort: AtlasComputeEffort) -> String {
        face(effort).subtitle
    }

    static func spokenInputLabel(bubblesEmpty: Bool) -> String {
        bubblesEmpty ? "mensagem para o Atlas" : "continuar conversa com o Atlas"
    }

    static func spokenInputHint(canSubmit: Bool, isExecuting: Bool) -> String {
        if canSubmit {
            return isExecuting
                ? "texto para a fila do próximo turno"
                : "texto do próximo envio"
        }
        return "escreva aqui para habilitar o envio"
    }

    static func spokenOptionsHint(sendHint: String) -> String {
        "modo, esforço e workspace; \(sendHint.lowercased())"
    }

    static func packFacts(effort: AtlasComputeEffort) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(effort)
        facts.append("composer_effort_face: \(face.productWord)")
        facts.append("composer_effort_short: \(effort.shortLabel)")
        if effort == .auto {
            absences.append("esforço auto — Atlas Decide escolhe; sem nível no payload")
        } else if let payload = effort.payloadValue {
            facts.append("composer_effort_payload: \(payload)")
        }
        return (facts, absences)
    }
}
