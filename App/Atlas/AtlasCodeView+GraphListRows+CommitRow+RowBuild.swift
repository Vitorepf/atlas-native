import SwiftUI
import AtlasCore

// Row build — peel de AtlasCodeView+GraphListRows+CommitRow.
// Init → AtlasCodeView+GraphListRows+CommitRow+RowBuild+Init.swift
// Handlers → AtlasCodeView+GraphListRows+CommitRow+RowBuild+Handlers.swift

extension AtlasCodeView {
    func graphCommitRowView(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int,
        filteredNodes: [AtlasCodeGraphNode]
    ) -> AtlasCodeCommitRow {
        let initArgs = graphCommitRowInit(
            node: node,
            index: index,
            total: total,
            filteredNodes: filteredNodes
        )
        let handlers = graphCommitRowHandlers(for: node)
        return AtlasCodeCommitRow(
            node: initArgs.node,
            state: initArgs.state,
            ruleId: initArgs.ruleId,
            trunk: initArgs.trunk,
            isFirst: initArgs.isFirst,
            isLast: initArgs.isLast,
            aboveState: initArgs.aboveState,
            belowState: initArgs.belowState,
            isDimmed: initArgs.isDimmed,
            onTap: handlers.onSelect,
            onLongPress: handlers.onLongPress,
            onAsk: handlers.onAsk
        )
    }
}
