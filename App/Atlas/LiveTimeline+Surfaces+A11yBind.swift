import SwiftUI
import AtlasCore

// A11y bind — peel de LiveTimeline+Surfaces.

extension LiveTimeline {
    func filterSilenceA11y<V: View>(_ content: V) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(LiveTimelineA11y.spokenFilterSilenceSurface(filter: filter,
                                                                            totalSteps: baseRows.count))
            .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
    }
}
