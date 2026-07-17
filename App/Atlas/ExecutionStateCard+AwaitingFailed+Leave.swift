import SwiftUI
import AtlasCore

// Leave helpers — peel de ExecutionStateCard+AwaitingFailed.
// Retry → ExecutionStateCard+AwaitingFailed+Retry.swift

extension ExecutionStateCard {
    /// «Pode sair» só quando o contrato pausa o timer ou o servidor já publicou essa copy.
    var leaveScreenKicker: String? {
        guard state.kind == .awaitingExternal else { return nil }
        if Self.copyMentionsCanLeave(state.detail) || Self.copyMentionsCanLeave(state.title) {
            return nil
        }
        guard state.timer?.timing == .paused else { return nil }
        return "Você pode sair desta tela"
    }
}
