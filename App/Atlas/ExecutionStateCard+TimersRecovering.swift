import SwiftUI
import AtlasCore

// Recovering / spoken timer — peel de ExecutionStateCard+Timers.

extension ExecutionStateCard {
    var recoveringTimerText: String? {
        guard state.kind == .recovering, let timer = state.timer else { return nil }
        return "ativo \(Self.clock(timer.elapsedActiveMilliseconds))"
    }

    var spokenTimerFragment: String? {
        frozenTimerA11y ?? recoveringTimerText
    }
}
