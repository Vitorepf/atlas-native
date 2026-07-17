import SwiftUI
import AtlasCore

// Spoken detail — peel de ExecutionStateCard+AwaitingFailed+Spoken.

extension ExecutionStateCard {
    func spokenDetailParts(into parts: inout [String]) {
        if let reason = spokenFailureReason {
            parts.append(reason)
        } else if let detail = state.detail {
            parts.append(detail)
        }
        if let kicker = leaveScreenKicker { parts.append(kicker) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
    }
}
