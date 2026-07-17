import SwiftUI
import AtlasCore

// Corpo quieto — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    var digestQuietBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption("operação", role: .header)
            Text("Quieta nesta janela — nenhuma entrega, pendência nem incidente publicado.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosOperationDigestA11y.spokenQuiet())
        .accessibilityIdentifier(A11yID.autonomosOperationQuiet)
    }
}
