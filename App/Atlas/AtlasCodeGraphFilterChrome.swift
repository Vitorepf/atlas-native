import SwiftUI
import AtlasCore

// WAVE-156 density peel — graph filter chips

extension AtlasCodeView {
    // MARK: Filter chips

    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(AtlasCodeGraphStateFilter.grafoTabs) { option in
                let active = graphStateFilter == option
                let count = option.count(in: graph.nodes, model: model)
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        graphFilterTouchedByOperator = true
                        graphStateFilter = option
                    }
                } label: {
                    graphStateChipLabel(option, count: count, active: active)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    AtlasCodeGraphJudgment.spokenFilterChip(
                        option, count: count, active: active, silent: active && filterSilence
                    )
                )
                .accessibilityAddTraits(active ? .isSelected : [])
                .accessibilityIdentifier(A11yID.codeGraphFilter(option.rawValue))
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AtlasTheme.separator.opacity(0.85))
                .frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }

    func graphStateChipLabel(_ option: AtlasCodeGraphStateFilter, count: Int, active: Bool) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 3) {
                Text(option.label)
                    .atlasSans(11.5, .medium)
                Text("\(count)")
                    .font(AtlasFont.mono(10))
                    .opacity(0.55)
            }
            .foregroundStyle(tabForeground(option, active: active))
            .monospacedDigit()

            Rectangle()
                .fill(active ? tabUnderline(option) : Color.clear)
                .frame(height: 1.5)
                .shadow(color: active ? tabUnderline(option).opacity(0.35) : .clear, radius: 4, y: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    func tabForeground(_ option: AtlasCodeGraphStateFilter, active: Bool) -> Color {
        guard active else { return AtlasTheme.textTertiary }
        return option == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary
    }

    func tabUnderline(_ option: AtlasCodeGraphStateFilter) -> Color {
        option == .violating ? AtlasCodePalette.alert : AtlasTheme.accent
    }
}
