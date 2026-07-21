import AtlasCore

// Cycle 041 fuse → AtlasFailureCopy+Hint.swift

extension AtlasFailureCopy {
    static func authServerHint(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .maintenance: return "O servidor pediu uma pausa via Retry-After. O app aguarda você tentar de novo quando a janela terminar."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        default: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHint(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        default: return nil
        }
    }
}

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

extension AtlasFailureCopy {
    static func hint(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        guard let kind else {
            return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
        return networkHint(kind: kind) ?? authServerHint(kind: kind)
    }
}
