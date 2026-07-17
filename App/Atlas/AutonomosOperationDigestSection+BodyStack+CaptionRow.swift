import SwiftUI
import AtlasCore

// Caption row — peel de AutonomosOperationDigestSection+BodyStack.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalCaptionRow: some View {
        HStack {
            AutonomosChrome.sectionCaption("RESUMO DA OPERAÇÃO")
            Spacer()
            Text(incidentPresent ? "requer você" : "por exceção")
                .font(AtlasFont.mono(9))
                .foregroundStyle(incidentPresent ? AtlasTheme.domOperacional : AtlasTheme.domAutonomos)
                .accessibilityHidden(true)
        }
    }
}
