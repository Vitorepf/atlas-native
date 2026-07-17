import SwiftUI
import AtlasCore

// Chip motion — peel de AutonomosDigestSection+LastChips.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestChipsMotion<Content: View>(_ content: Content, counts: AtlasAutonomosDigestCounts) -> some View {
        content
            .animation(reduceMotion ? nil : .default, value: counts.delivered)
            .animation(reduceMotion ? nil : .default, value: counts.risks)
            .animation(reduceMotion ? nil : .default, value: counts.pendingDecisions)
    }
}
