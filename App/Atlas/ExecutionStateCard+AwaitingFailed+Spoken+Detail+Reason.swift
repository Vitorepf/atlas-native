import SwiftUI
import AtlasCore

// Spoken reason/detail — peel de ExecutionStateCard+AwaitingFailed+Spoken+Detail.

extension ExecutionStateCard {
    func spokenReasonParts(into parts: inout [String]) {
        if let reason = spokenFailureReason {
            parts.append(reason)
        } else if let detail = state.detail {
            parts.append(detail)
        }
    }
}
