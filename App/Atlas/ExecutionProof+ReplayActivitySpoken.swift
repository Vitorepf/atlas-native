import SwiftUI
import AtlasCore

// Activity spoken — peel de ExecutionProof+ReplayQuality.

extension ExecutionProof {
    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }
}
