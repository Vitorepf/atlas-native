import SwiftUI
import AtlasCore

// Spoken tail — peel de ExecutionStateCard+AwaitingFailed+Spoken+Summary.

extension ExecutionStateCard {
    func spokenSummaryTail(into parts: inout [String]) {
        spokenDetailParts(into: &parts)
        spokenTimingParts(into: &parts)
    }
}
