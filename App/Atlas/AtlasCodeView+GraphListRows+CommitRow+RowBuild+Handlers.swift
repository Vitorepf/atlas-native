import SwiftUI
import AtlasCore

// Commit row handlers — peel de AtlasCodeView+GraphListRows+CommitRow+RowBuild.

extension AtlasCodeView {
    func graphCommitRowHandlers(for node: AtlasCodeGraphNode) -> (
        onSelect: () -> Void,
        onLongPress: () -> Void
    ) {
        (
            onSelect: { graphCommitRowSelect(node) },
            onLongPress: { graphCommitRowLongPress(node) }
        )
    }
}
