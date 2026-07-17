import AtlasCore

/// Copy editorial por `AtlasNetworkFailureKind` — home e conversa compartilham
/// a mesma voz (offline × timeout × recusada × …). Presentation-only.
/// Hint → AtlasFailureCopy+Hint.swift
enum AtlasFailureCopy {
    static func headline(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Falta a chave do Atlas." }
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        case .other, nil: return "O servidor está fora de alcance."
        }
    }
}
