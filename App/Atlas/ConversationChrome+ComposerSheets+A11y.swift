import Foundation
import AtlasCore

// Spoken labels dos sheets do composer (modo / workspace / effort) — fusão idle.

enum ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"
    static let modeSheetHint = "escolhe um rótulo local; não altera o turno ainda"
    static let effortSheetHint = "escolhe o esforço computacional do próximo envio"
    static let workspaceSheetHint = "escolhe a pasta do próximo envio entre as conversas carregadas"
    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }

    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenEffort(effort)), \(state)"
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

    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        }
    }
}
