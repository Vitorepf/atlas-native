import SwiftUI
import AtlasCore

// Spoken kicker/checkpoint — peel de ExecutionStateCard+AwaitingFailed+Spoken+Detail.

extension ExecutionStateCard {
    func spokenMetaParts(into parts: inout [String]) {
        if let kicker = leaveScreenKicker { parts.append(kicker) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
    }
}
