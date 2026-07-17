import SwiftUI
import AtlasCore

// Card do digest — peel de AutonomosDigestSection.
// Schedule → AutonomosDigestSection+ScheduleCopy.swift
// Chrome → AutonomosDigestSection+CardChrome.swift
// Stack → AutonomosDigestSection+CardStack.swift

extension AutonomosNextDigestSection {
    var digestCard: some View {
        let last = hasLastDigest(digest)
        let window = digestWindowCaption(digest)
        return digestCardChrome {
            digestCardStack(last: last, window: window)
        }
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
