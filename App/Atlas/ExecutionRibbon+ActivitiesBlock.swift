import SwiftUI
import AtlasCore

// Activities timeline — peel de ExecutionRibbon.

extension ExecutionRibbon {
    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }
}
