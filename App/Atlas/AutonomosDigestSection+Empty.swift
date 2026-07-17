import SwiftUI
import AtlasCore

/// Digest carregado mas sem agenda nem último resumo — peel de AutonomosDigestSection.
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
