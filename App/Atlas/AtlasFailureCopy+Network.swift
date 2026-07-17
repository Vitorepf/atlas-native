import AtlasCore

/// Network reachability headlines — peel de AtlasFailureCopy.
/// Offline → AtlasFailureCopy+Network+Offline.swift

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
