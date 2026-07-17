import SwiftUI
import AtlasCore

// Card do digest — peel de AutonomosDigestSection.
// Schedule → AutonomosDigestSection+ScheduleCopy.swift

extension AutonomosNextDigestSection {
    var digestCard: some View {
        let last = hasLastDigest(digest)
        let window = digestWindowCaption(digest)
        return VStack(alignment: .leading, spacing: 10) {
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
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
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
