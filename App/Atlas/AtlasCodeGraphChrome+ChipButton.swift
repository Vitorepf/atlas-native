import SwiftUI
import AtlasCore

// Chip button label — peel de AtlasCodeGraphChrome+Chips.
// Label → AtlasCodeGraphChrome+ChipLabel.swift

extension AtlasCodeView {
    func graphStateChipButton(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        filterSilence: Bool
    ) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                graphStateFilter = option
            }
        } label: {
            graphStateChipLabel(option, count: count, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            AtlasCodeGraphA11y.spokenFilterChip(
                option, count: count, active: active, silent: active && filterSilence
            )
        )
        .accessibilityAddTraits(active ? .isSelected : [])
        .accessibilityIdentifier(A11yID.codeGraphFilter(option.rawValue))
    }
}
