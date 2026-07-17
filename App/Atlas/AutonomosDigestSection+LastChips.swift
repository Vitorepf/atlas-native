import SwiftUI
import AtlasCore

// Chips do último digest — peel de AutonomosDigestSection+Last.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestChips(_ digest: AtlasAutonomosDigestResponse) -> some View {
        HStack(spacing: 8) {
            if digest.last.counts.delivered > 0 {
                AutonomosChrome.digestChip("\(digest.last.counts.delivered)", "entregas")
            }
            if digest.last.counts.risks > 0 {
                AutonomosChrome.digestChip("\(digest.last.counts.risks)", "riscos")
            }
            if digest.last.counts.pendingDecisions > 0 {
                AutonomosChrome.digestChip("\(digest.last.counts.pendingDecisions)", "decisões")
            }
        }
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.delivered)
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.risks)
        .animation(reduceMotion ? nil : .default, value: digest.last.counts.pendingDecisions)
    }
}
