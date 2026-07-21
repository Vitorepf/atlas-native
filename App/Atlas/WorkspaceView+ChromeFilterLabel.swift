import SwiftUI
import AtlasCore

// Filter chip label — peel de WorkspaceView+ChromeFilterChip.

extension WorkspaceView {
    func areaFilterChipLabel(_ a: AtlasArea, active: Bool) -> some View {
        Text(a.label)
            .font(.system(.subheadline, weight: .medium))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(
                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            )
    }
}
