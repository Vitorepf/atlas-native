import SwiftUI
import AtlasCore

// Rows do grafo — peel de AtlasCodeView+GraphList.
// Row → AtlasCodeView+GraphListRows+CommitRow.swift

extension AtlasCodeView {
    @ViewBuilder
    func graphCommitRows(_ filteredNodes: [AtlasCodeGraphNode]) -> some View {
        ForEach(Array(filteredNodes.enumerated()), id: \.element.id) { index, node in
            graphCommitRow(
                node: node,
                index: index,
                total: filteredNodes.count,
                filteredNodes: filteredNodes
            )
        }
    }
}
