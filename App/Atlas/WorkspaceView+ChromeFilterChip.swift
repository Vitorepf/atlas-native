import SwiftUI
import AtlasCore

// Area filter chip — peel de WorkspaceView+ChromeFilter.

extension WorkspaceView {
    func areaFilterChip(_ a: AtlasArea, active: Bool) -> some View {
        Button {
            if reduceMotion {
                area = a
            } else {
                withAnimation(AtlasMotion.editorial) { area = a }
            }
        } label: {
            Text(a.label)
                .font(.system(.subheadline, weight: .medium))
                .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(
                    Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                        .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("área \(a.label)")
        .accessibilityHint("filtra conversas já carregadas")
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}
