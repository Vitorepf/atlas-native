import SwiftUI
import AtlasCore

// Cenas 04 (awaitingExternal) e 13 (failed) — peel de ExecutionStateCard (régua ≤100).
// Spoken → ExecutionStateCard+AwaitingFailed+Spoken.swift
// Leave/retry → ExecutionStateCard+AwaitingFailed+Leave.swift

extension ExecutionStateCard {
    /// Prazo só na espera externa; o campo `deadline` do contrato não vale para outros kinds.
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    /// Job para ações declaradas: atenção usa `jobId`; falha usa `retryableJobId` real.
    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
    }
}
