import SwiftUI

// Value + label stack — peel de AutonomosChrome+DigestChipBody.

extension DigestChipBody {
    var digestChipValueStack: some View {
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
    }
}
