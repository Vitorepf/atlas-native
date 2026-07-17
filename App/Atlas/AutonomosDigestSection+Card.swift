import SwiftUI
import AtlasCore

// Card do digest — peel de AutonomosDigestSection.
// Schedule → AutonomosDigestSection+ScheduleCopy.swift
// Chrome → AutonomosDigestSection+CardChrome.swift

extension AutonomosNextDigestSection {
    var digestCard: some View {
        let last = hasLastDigest(digest)
        let window = digestWindowCaption(digest)
        return digestCardChrome {
            VStack(alignment: .leading, spacing: 10) {
                AutonomosChrome.sectionCaption(sectionTitle)
                if last, let window {
                    Text(window)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .accessibilityHidden(true)
                }
                digestScheduleCopy(last: last)
                if last {
                    lastDigestBody(digest)
                }
            }
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
