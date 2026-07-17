import SwiftUI
import AtlasCore

// Spoken summary assembly — peel de ExecutionStateCard+AwaitingFailed+Spoken.

extension ExecutionStateCard {
    var spokenSummaryText: String {
        var parts: [String] = []
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
        spokenDetailParts(into: &parts)
        spokenTimingParts(into: &parts)
        return parts.joined(separator: ". ")
    }
}
