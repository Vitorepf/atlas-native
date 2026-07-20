import SwiftUI
import AtlasCore

// Single commit row — peel de AtlasCodeView+GraphListRows.
// RowBuild → AtlasCodeView+GraphListRows+CommitRow+RowBuild.swift
// Rotor → AtlasCodeView+GraphListRows+CommitRow+Rotor.swift

extension AtlasCodeView {
    @ViewBuilder
    func graphCommitRow(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int,
        filteredNodes: [AtlasCodeGraphNode]
    ) -> some View {
        graphCommitRowRotor(
            graphCommitRowView(
                node: node,
                index: index,
                total: total,
                filteredNodes: filteredNodes
            ),
            node: node
        )
    }
}
