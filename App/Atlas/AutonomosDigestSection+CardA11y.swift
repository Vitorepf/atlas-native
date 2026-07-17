import SwiftUI
import AtlasCore

// Digest a11y — peel de AutonomosDigestSection+Card.

extension AutonomosNextDigestSection {
    func digestA11yChrome<Content: View>(last: Bool, window: String?, _ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosDigestSectionA11y.spokenSection(
                nextDigestAt: digest.nextDigestAt,
                scheduleReason: digest.schedule.reason,
                hasLast: last,
                windowCaption: window,
                counts: digest.last.counts,
                mergeHash: digestMergeTag(digest),
                riskHeadline: digestRiskHeadline(digest),
                decisionTitle: digestDecisionHeadline(digest)
            ))
            .accessibilityIdentifier(A11yID.autonomosDigestSection)
    }
}
