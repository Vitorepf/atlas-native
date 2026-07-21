import SwiftUI
import AtlasCore

// Timestamped activities — peel de ExecutionProof+Replay.

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }
}
