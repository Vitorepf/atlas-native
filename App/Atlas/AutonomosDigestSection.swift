import SwiftUI
import AtlasCore

// MARK: - Próximo / último resumo (M09)

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if shouldShowDigest(digest) {
            digestCard
        } else {
            AutonomosDigestEmptyState()
        }
    }

    private var digestCard: some View {
        let last = hasLastDigest(digest)
        let window = digestWindowCaption(digest)
        return VStack(alignment: .leading, spacing: 10) {
            AutonomosChrome.sectionCaption(sectionTitle)
                .accessibilityHidden(true)
            if last, let window {
                Text(window)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            if let next = digest.nextDigestAt?.nonEmpty {
                Text(next)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .textSelection(.enabled)
                    .accessibilityHidden(true)
            } else if last {
                Text("sem agenda publicada — último resumo abaixo")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            } else if let reason = digest.schedule.reason?.nonEmpty {
                Text(reason)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
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

    private var sectionTitle: String {
        digest.nextDigestAt?.nonEmpty != nil ? "PRÓXIMO RESUMO" : "RESUMO GOVERNADO"
    }
}
