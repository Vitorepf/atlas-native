import SwiftUI
import AtlasCore

// Row build — peel de AtlasCodeView+GraphListRows+CommitRow.

extension AtlasCodeView {
    func graphCommitRowView(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int
    ) -> AtlasCodeCommitRow {
        AtlasCodeCommitRow(
            node: node,
            state: model.state(for: node),
            ruleId: model.ruleId(for: node),
            trunk: model.violations?.trunk,
            isFirst: index == 0,
            isLast: index == total - 1,
            isDimmed: !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
        ) {
            graphCommitRowSelect(node)
        } onLongPress: {
            graphCommitRowLongPress(node)
        }
    }
}
