import SwiftUI
import AtlasCore

// Detail chip label — peel de AutonomosAwaitingSection+Blocks.

extension AutonomosDetailChipButton {
    var chipLabel: some View {
        Text(label)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Capsule().fill(AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityHidden(true)
    }
}
