import SwiftUI
import AtlasCore

// Filter chip visuals — peel de RootHomeSections+Chip.

extension RootHomeSections {
    func homeFilterChipLabel(_ label: String, active: Bool) -> some View {
        Text(label)
            .font(.system(.caption, weight: .medium))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: active)
    }
}
