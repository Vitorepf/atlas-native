import SwiftUI
import AtlasCore

// State filter chips — peel de AtlasCodeGraphChrome+Filters.
// Chip button → AtlasCodeGraphChrome+ChipButton.swift

extension AtlasCodeView {
    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(AtlasCodeGraphStateFilter.allCases) { option in
                    let active = graphStateFilter == option
                    let count = option.count(in: graph.nodes, model: model)
                    graphStateChipButton(option, count: count, active: active, filterSilence: filterSilence)
                }
            }
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }
}
