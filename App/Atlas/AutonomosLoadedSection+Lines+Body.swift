import SwiftUI
import AtlasCore

// Info line body — peel de AutonomosLoadedSection+Lines.

extension AutonomosInfoLine {
    var infoLineBody: some View {
        infoLineCard(text)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(.isStaticText)
            .modifier(OptionalA11yIdentifier(identifier))
    }
}
