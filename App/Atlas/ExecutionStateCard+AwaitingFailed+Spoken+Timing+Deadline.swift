import SwiftUI
import AtlasCore

// Spoken deadline + action — peel de ExecutionStateCard+AwaitingFailed+Spoken+Timing.

extension ExecutionStateCard {
    func spokenDeadlineParts(into parts: inout [String]) {
        if let deadline = publishedExternalDeadline { parts.append("próxima mudança \(deadline)") }
        if let action = spokenActionFragment { parts.append(action) }
    }
}
