import SwiftUI
import AtlasCore

// Lista filtrada do grafo — peel de AtlasCodeView+Graph.
// Tail → AtlasCodeView+GraphListTail.swift
// Rows → AtlasCodeView+GraphListRows.swift
// Scroll → AtlasCodeView+GraphListScroll.swift

extension AtlasCodeView {
    func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        let filteredNodes = graphStateFilter.nodes(in: graph.nodes, model: model)
        let filterSilence = graphStateFilter != .all && filteredNodes.isEmpty
        let scroll = graphListScroll(
            graph: graph,
            filteredNodes: filteredNodes,
            filterSilence: filterSilence
        )
        return graphAccessibilityRotors(graph: graph, content: scroll)
    }
}
