import Foundation

// Dial de esforço computacional — canon compartilhado desktop/mobile (porte de
// @atlas/rich-input-canon computeEffort.ts). O default `.auto` NÃO manda nível
// nenhum pro backend: deixa o Atlas Decide escolher esforço por tarefa/domínio/
// orçamento/evidência. É a tese do Atlas no gesto — o operador pode forçar, mas
// por padrão o cérebro decide.
public enum AtlasComputeEffort: String, CaseIterable, Sendable {
    case auto, fast, balanced, deep, max

    public var next: AtlasComputeEffort {
        let all = Self.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }

    public var shortLabel: String {
        switch self {
        case .auto: return "auto"
        case .fast: return "rápido"
        case .balanced: return "normal"
        case .deep: return "profundo"
        case .max: return "máximo"
        }
    }

    /// `.auto` → nil (Atlas Decide escolhe); senão o rawValue vai no payload.
    public var payloadValue: String? { self == .auto ? nil : rawValue }
}
