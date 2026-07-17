import SwiftUI
import AtlasCore

// Commit row init — peel de AtlasCodeView+GraphListRows+CommitRow+RowBuild.

extension AtlasCodeView {
    func graphCommitRowInit(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int
    ) -> (
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?,
        isFirst: Bool,
        isLast: Bool,
        isDimmed: Bool
    ) {
        (
            node: node,
            state: model.state(for: node),
            ruleId: model.ruleId(for: node),
            trunk: model.violations?.trunk,
            isFirst: index == 0,
            isLast: index == total - 1,
            isDimmed: !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
        )
    }
}
