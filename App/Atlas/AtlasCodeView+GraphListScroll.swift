import SwiftUI
import AtlasCore

// Graph list scroll stack — peel de AtlasCodeView+GraphList.
// Body → AtlasCodeView+GraphListScrollBody.swift

extension AtlasCodeView {
    func graphListScroll(
        graph: AtlasCodeGraphResponse,
        filteredNodes: [AtlasCodeGraphNode],
        filterSilence: Bool
    ) -> some View {
        ScrollView {
            graphListScrollBody(
                graph: graph,
                filteredNodes: filteredNodes,
                filterSilence: filterSilence
            )
        }
        .refreshable {
            await model.load()
            await mirrorModel.refresh()
        }
    }
}
