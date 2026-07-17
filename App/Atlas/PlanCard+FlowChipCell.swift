import SwiftUI
import AtlasCore

// Single chip cell — peel de PlanCard+FlowChips.

extension PlanFlowChips {
    func flowChipCell(_ item: String) -> some View {
        Text(item)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textSecondary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}
