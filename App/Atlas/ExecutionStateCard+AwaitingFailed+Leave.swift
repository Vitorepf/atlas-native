import SwiftUI
import AtlasCore

// Leave / retry helpers — peel de ExecutionStateCard+AwaitingFailed.

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

    var showsRetryFallback: Bool {
        state.kind == .failed
            && state.actions.isEmpty
            && retryableJobId != nil
    }

    static func copyMentionsCanLeave(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        return text.contains("pode sair")
    }
}
