import SwiftUI
import AtlasCore

struct AutonomosDetailChipButton: View {
    let label: String
    let kind: AutonomosDetailSheet
    var spokenLabel: String? = nil
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            chipLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(AutonomosDetailChipButtonA11y.spokenLabel(label: label, spoken: spokenLabel))
        .accessibilityHint(AutonomosDetailChipButtonA11y.hint(kind: kind))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosDetailButton(kind.id))
    }
}
