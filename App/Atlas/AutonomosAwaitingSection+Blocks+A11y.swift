import SwiftUI
import AtlasCore

// Detail chip a11y — peel de AutonomosAwaitingSection+Blocks.

extension View {
    func autonomosDetailChipA11y(
        label: String,
        spokenLabel: String?,
        kind: AutonomosDetailSheet
    ) -> some View {
        self
            .accessibilityLabel(AutonomosDetailChipButtonA11y.spokenLabel(label: label, spoken: spokenLabel))
            .accessibilityHint(AutonomosDetailChipButtonA11y.hint(kind: kind))
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.autonomosDetailButton(kind.id))
    }
}
