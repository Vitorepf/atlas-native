import SwiftUI
import AtlasCore

// Frozen timer a11y — peel de ExecutionStateCard+Timers.

extension ExecutionStateCard {
    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}
