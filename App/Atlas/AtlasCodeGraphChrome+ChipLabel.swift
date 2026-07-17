import SwiftUI
import AtlasCore

// Chip label — peel de AtlasCodeGraphChrome+ChipButton.

extension AtlasCodeView {
    func graphStateChipLabel(_ option: AtlasCodeGraphStateFilter, count: Int, active: Bool) -> some View {
        Text("\(option.label) \(count)")
            .font(AtlasFont.mono(9))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .monospacedDigit()
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
