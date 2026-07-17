import SwiftUI
import AtlasCore

// Chip a11y modifiers — peel de AtlasCodeGraphChrome+ChipButton.

extension View {
    func graphStateChipA11y(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        filterSilence: Bool
    ) -> some View {
        self
            .accessibilityLabel(
                AtlasCodeGraphA11y.spokenFilterChip(
                    option, count: count, active: active, silent: active && filterSilence
                )
            )
            .accessibilityAddTraits(active ? .isSelected : [])
            .accessibilityIdentifier(A11yID.codeGraphFilter(option.rawValue))
    }
}
