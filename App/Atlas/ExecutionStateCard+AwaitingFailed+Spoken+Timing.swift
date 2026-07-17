import SwiftUI
import AtlasCore

// Spoken timing — peel de ExecutionStateCard+AwaitingFailed+Spoken.

extension ExecutionStateCard {
    func spokenTimingParts(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
        if let deadline = publishedExternalDeadline { parts.append("próxima mudança \(deadline)") }
        if let action = spokenActionFragment { parts.append(action) }
    }
}
