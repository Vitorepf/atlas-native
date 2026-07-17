import SwiftUI
import AtlasCore

struct AutonomosDetailChipButton: View {
    let label: String
    let kind: AutonomosDetailSheet
    var spokenLabel: String? = nil
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            if !reduceMotion {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
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

struct AutonomosRhythmLearningLine: View {
    let sampleDays: Int?

    var body: some View {
        if let sampleDays, sampleDays < 4 {
            Text("aprendendo seu ritmo · dia \(max(1, sampleDays)) de 4")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("aprendendo seu ritmo, dia \(max(1, sampleDays)) de 4")
        }
    }
}
