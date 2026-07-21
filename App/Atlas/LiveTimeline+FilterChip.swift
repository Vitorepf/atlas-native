import SwiftUI
import AtlasCore

// Label visual do chip — peel de TimelineFilterChips.

extension TimelineFilterChips {
    func chipLabel(_ option: TimelineReadFilter, active: Bool) -> some View {
        Text(option.label)
            .font(AtlasFont.mono(9))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.bgRecessed))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
