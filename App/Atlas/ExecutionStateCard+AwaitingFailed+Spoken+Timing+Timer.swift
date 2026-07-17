import SwiftUI
import AtlasCore

// Spoken timer — peel de ExecutionStateCard+AwaitingFailed+Spoken+Timing.

extension ExecutionStateCard {
    func spokenTimerPart(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
    }
}
