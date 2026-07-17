import AtlasCore

/// Network reachability hints — peel de AtlasFailureCopy+Hint.
/// Offline → AtlasFailureCopy+Hint+Network+Offline.swift

extension AtlasFailureCopy {
    static func networkHint(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHint(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        default: return nil
        }
    }
}
