import SwiftUI
import AtlasCore

// Single commit row — peel de AtlasCodeView+GraphListRows.

extension AtlasCodeView {
    @ViewBuilder
    func graphCommitRow(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int,
        filteredNodes: [AtlasCodeGraphNode]
    ) -> some View {
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
        .accessibilityRotorEntry(id: node.id, in: graphRotor)
    }
}
