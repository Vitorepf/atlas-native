import AtlasCore

/// Network reachability headlines — peel de AtlasFailureCopy.

extension AtlasFailureCopy {
    static func networkHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        default: return nil
        }
    }
}
