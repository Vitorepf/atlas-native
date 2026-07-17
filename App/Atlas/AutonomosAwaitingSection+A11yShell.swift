import SwiftUI
import AtlasCore

// A11y chrome awaiting — peel de AutonomosAwaitingSection.

extension AutonomosAwaitingYouSection {
    var awaitingA11y: some View {
        awaitingChrome
            .accessibilityElement(children: .contain)
            .accessibilityLabel(sectionSpokenLabel)
            .accessibilityHint("abre inbox ou ordens com decisão pública pendente")
            .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: decisionCount)
    }
}
