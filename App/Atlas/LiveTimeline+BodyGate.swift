import SwiftUI
import AtlasCore

// Body branches — peel de LiveTimeline.

extension LiveTimeline {
    @ViewBuilder
    var timelineBody: some View {
        if baseRows.isEmpty {
            EmptyView()
        } else if rows.isEmpty {
            filterSilenceSurface
        } else {
            timelineSurface
        }
    }
}
