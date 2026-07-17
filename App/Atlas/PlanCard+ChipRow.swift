import SwiftUI
import AtlasCore

// Plan chip row — peel de PlanCard+DetailChips.

extension PlanCard {
    func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            PlanFlowChips(items: items)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenChipRow(label: label, items: items))
    }
}
