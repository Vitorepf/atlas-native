import AtlasCore

// Cycle 041 fuse → AtlasFailureCopy+Network.swift

extension AtlasFailureCopy {
    static func authServerHeadline(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        default: return "O servidor está fora de alcance."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHeadline(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHeadline(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        default: return nil
        }
    }
}
