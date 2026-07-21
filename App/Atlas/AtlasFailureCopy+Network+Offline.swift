import AtlasCore

/// Offline/timeout headlines — peel de AtlasFailureCopy+Network.

extension AtlasFailureCopy {
    static func networkOfflineHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        default: return nil
        }
    }
}
