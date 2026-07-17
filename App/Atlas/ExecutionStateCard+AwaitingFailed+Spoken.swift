import SwiftUI
import AtlasCore

// Spoken awaiting/failed — peel de ExecutionStateCard+AwaitingFailed.

extension ExecutionStateCard {
    var spokenSummary: String {
        var parts: [String] = []
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
        if let reason = spokenFailureReason {
            parts.append(reason)
        } else if let detail = state.detail {
            parts.append(detail)
        }
        if let kicker = leaveScreenKicker { parts.append(kicker) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        if let fragment = spokenTimerFragment { parts.append(fragment) }
        if let deadline = publishedExternalDeadline { parts.append("próxima mudança \(deadline)") }
        if !state.actions.isEmpty {
            parts.append("\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis")
        } else if showsRetryFallback {
            parts.append("retomar disponível")
        }
        return parts.joined(separator: ". ")
    }

    /// Cena 13: o motivo falado vem do `detail` publicado pelo servidor.
    var spokenFailureReason: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo: \(detail)"
    }

    var failureReasonA11y: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo da falha: \(detail)"
    }
}
