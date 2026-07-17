import SwiftUI
import AtlasCore

// MARK: - Próximo / último resumo (M09)

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse

    var body: some View {
        if shouldShowDigest(digest) {
            VStack(alignment: .leading, spacing: 10) {
                AutonomosChrome.sectionCaption(sectionTitle)
                if let next = digest.nextDigestAt?.nonEmpty {
                    Text(next)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .textSelection(.enabled)
                        .accessibilityLabel("próximo digest agendado para \(next)")
                } else if hasLastDigest(digest) {
                    Text("sem agenda publicada — último resumo abaixo")
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else if let reason = digest.schedule.reason?.nonEmpty {
                    Text(reason)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if hasLastDigest(digest) {
                    lastDigestBody(digest)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityIdentifier(A11yID.autonomosDigestSection)
        } else {
            AutonomosDigestEmptyState()
        }
    }

    private var sectionTitle: String {
        digest.nextDigestAt?.nonEmpty != nil ? "PRÓXIMO RESUMO" : "RESUMO GOVERNADO"
    }

    @ViewBuilder
    private func lastDigestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
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
        if let delivered = digest.last.delivered.first {
            AutonomosChrome.tag("merge \(String(delivered.mergeHash.prefix(8)))")
        }
        if let risk = digest.last.risks.first {
            Text(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
        }
        if let decision = digest.last.pendingDecisions.first {
            Text(decision.title)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
        }
    }

    private func shouldShowDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.nextDigestAt?.nonEmpty != nil
            || hasLastDigest(digest)
            || digest.schedule.reason?.nonEmpty != nil
    }

    private func hasLastDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.last.counts.delivered > 0
            || digest.last.counts.risks > 0
            || digest.last.counts.pendingDecisions > 0
            || !digest.last.delivered.isEmpty
            || !digest.last.risks.isEmpty
            || !digest.last.pendingDecisions.isEmpty
    }
}

/// Digest carregado mas sem agenda nem último resumo — honesto, não inventa horário.
struct AutonomosDigestEmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption("resumo")
            Text("Digest ainda não agendado pelo servidor — sem next_digest_at neste recorte.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("digest não agendado pelo servidor")
        .accessibilityIdentifier(A11yID.autonomosDigestEmpty)
    }
}
