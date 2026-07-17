import SwiftUI

// Corpo visual do chip — peel de AutonomosChrome+DigestChip.

struct DigestChipBody: View {
    let value: String
    let label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 5) {
            Text(value)
                .font(AtlasFont.mono(14))
                .foregroundStyle(AtlasTheme.accent)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            Text(label)
                .font(.caption2)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
        .accessibilityHidden(true)
    }
}
