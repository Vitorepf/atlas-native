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
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Capsule().fill(AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
                .accessibilityHidden(true)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(AutonomosDetailChipButtonA11y.spokenLabel(label: label, spoken: spokenLabel))
        .accessibilityHint(AutonomosDetailChipButtonA11y.hint(kind: kind))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosDetailButton(kind.id))
    }
}
