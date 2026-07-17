import SwiftUI
import AtlasCore

// Header awaiting — peel de AutonomosAwaitingSection.

extension AutonomosAwaitingYouSection {
    var awaitingHeader: some View {
        HStack {
            AutonomosChrome.sectionCaption("AGUARDANDO VOCÊ", role: .header)
            Spacer()
            Text("\(decisionCount)")
                .font(AtlasFont.mono(13))
                .foregroundStyle(AtlasTheme.domOperacional)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}
