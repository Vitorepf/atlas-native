import SwiftUI
import AtlasCore

// Signal stack — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AutonomosChrome.sectionCaption("RESUMO DA OPERAÇÃO")
                Spacer()
                Text(incidentPresent ? "requer você" : "por exceção")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(incidentPresent ? AtlasTheme.domOperacional : AtlasTheme.domAutonomos)
                    .accessibilityHidden(true)
            }
            Text(AutonomosOperationDigestA11y.displayHeadline(
                delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            digestSignalMeta
        }
    }
}
