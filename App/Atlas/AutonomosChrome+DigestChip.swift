import SwiftUI

// Chip numérico do digest — metadado visual; spoken composto vive no container pai.
extension AutonomosChrome {
    @ViewBuilder
    static func digestChip(_ value: String, _ label: String) -> some View {
        DigestChip(value: value, label: label)
    }
}

private struct DigestChip: View {
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
