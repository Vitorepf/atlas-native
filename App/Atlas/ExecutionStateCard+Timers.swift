import SwiftUI
import AtlasCore

// Timers congelados — peel de ExecutionStateCard+Presentation.
// Recovering → ExecutionStateCard+TimersRecovering.swift
// A11y → ExecutionStateCard+TimersA11y.swift

extension ExecutionStateCard {
    /// Timer congelado (‖) — paridade Island/Lock para `.attentionRequired` e
    /// `.awaitingExternal` quando o servidor publica `timing: paused`.
    var frozenTimerText: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "‖ \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}
