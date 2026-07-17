import SwiftUI
import AtlasCore

// Cenas 04 (awaitingExternal) e 13 (failed) — peel de ExecutionStateCard (régua ≤100).
// Spoken → ExecutionStateCard+AwaitingFailed+Spoken.swift

extension ExecutionStateCard {
    /// Prazo só na espera externa; o campo `deadline` do contrato não vale para outros kinds.
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    /// «Pode sair» só quando o contrato pausa o timer ou o servidor já publicou essa copy.
    var leaveScreenKicker: String? {
        guard state.kind == .awaitingExternal else { return nil }
        if Self.copyMentionsCanLeave(state.detail) || Self.copyMentionsCanLeave(state.title) {
            return nil
        }
        guard state.timer?.timing == .paused else { return nil }
        return "Você pode sair desta tela"
    }

    /// Job para ações declaradas: atenção usa `jobId`; falha usa `retryableJobId` real.
    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
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
