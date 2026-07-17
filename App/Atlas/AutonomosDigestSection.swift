import SwiftUI
import AtlasCore

// MARK: - Próximo / último resumo (M09)

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse

    var body: some View {
        if shouldShowDigest(digest) {
            VStack(alignment: .leading, spacing: 10) {
                AutonomosChrome.sectionCaption(sectionTitle)
                if hasLastDigest(digest), let window = digestWindowCaption(digest) {
                    Text(window)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .accessibilityLabel("último resumo, \(window)")
                }
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
}
