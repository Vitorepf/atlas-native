import SwiftUI
import AtlasCore

// Area filter chip — peel de WorkspaceView+ChromeFilter.
// Label → WorkspaceView+ChromeFilterLabel.swift

extension WorkspaceView {
    func areaFilterChip(_ a: AtlasArea, active: Bool) -> some View {
        Button {
            if reduceMotion {
                area = a
            } else {
                withAnimation(AtlasMotion.editorial) { area = a }
            }
        } label: {
            areaFilterChipLabel(a, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("área \(a.label)")
        .accessibilityHint("filtra conversas já carregadas")
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}
