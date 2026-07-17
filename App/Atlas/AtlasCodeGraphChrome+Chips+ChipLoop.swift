import SwiftUI
import AtlasCore

// State filter chip loop — peel de AtlasCodeGraphChrome+Chips.

extension AtlasCodeView {
    @ViewBuilder
    func graphStateChipLoop(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        ForEach(AtlasCodeGraphStateFilter.allCases) { option in
            let active = graphStateFilter == option
            let count = option.count(in: graph.nodes, model: model)
            graphStateChipButton(option, count: count, active: active, filterSilence: filterSilence)
        }
    }
}
