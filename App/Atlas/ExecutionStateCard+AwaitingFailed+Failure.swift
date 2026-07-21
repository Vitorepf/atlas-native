import SwiftUI
import AtlasCore

// Failure reason spoken — peel de ExecutionStateCard+AwaitingFailed+Spoken.

extension ExecutionStateCard {
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
