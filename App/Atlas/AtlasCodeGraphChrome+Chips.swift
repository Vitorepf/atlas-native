import SwiftUI
import AtlasCore

// State filter chips — peel de AtlasCodeGraphChrome+Filters.

extension AtlasCodeView {
    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(AtlasCodeGraphStateFilter.allCases) { option in
                    let active = graphStateFilter == option
                    let count = option.count(in: graph.nodes, model: model)
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
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }
}
