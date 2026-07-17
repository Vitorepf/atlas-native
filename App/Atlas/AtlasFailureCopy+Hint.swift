import AtlasCore

// Hint copy — peel de AtlasFailureCopy.
// Network → AtlasFailureCopy+Hint+Network.swift
// AuthServer → AtlasFailureCopy+Hint+AuthServer.swift

extension AtlasFailureCopy {
    static func hint(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        guard let kind else {
            return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
        return networkHint(kind: kind) ?? authServerHint(kind: kind)
    }
}
