import SwiftUI
import AtlasCore

// Chip button label — peel de AtlasCodeGraphChrome+Chips.

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
            Text("\(option.label) \(count)")
                .font(AtlasFont.mono(9))
                .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .monospacedDigit()
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
                .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
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
