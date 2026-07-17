import SwiftUI
import AtlasCore

// Empty self delivered — peel de AutonomosAreaDeliveredSection.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    var deliveredEmptySelf: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption("AUTO-CONSTRUÇÃO", role: .header)
            Text("Trabalho ainda não mergeado — aguardando o ledger. Sem entrega comprovada neste recorte.")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenEmptySelf())
        .accessibilityIdentifier(A11yID.autonomosAreaDeliveredEmpty)
    }
}
