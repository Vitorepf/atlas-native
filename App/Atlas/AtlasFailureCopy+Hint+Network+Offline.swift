import AtlasCore

/// Offline/timeout hints — peel de AtlasFailureCopy+Hint+Network.

extension AtlasFailureCopy {
    static func networkOfflineHint(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        default: return nil
        }
    }
}
