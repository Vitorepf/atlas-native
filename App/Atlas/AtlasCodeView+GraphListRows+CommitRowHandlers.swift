import SwiftUI
import AtlasCore

// Tap handlers — peel de AtlasCodeView+GraphListRows+CommitRow.

extension AtlasCodeView {
    func graphCommitRowSelect(_ node: AtlasCodeGraphNode) {
        selectedNode = node
        Task { await provenanceModel.load(hash: node.hash) }
    }

    func graphCommitRowLongPress(_ node: AtlasCodeGraphNode) {
        guard visibleAnchors.contains(node.hash) else { return }
        Task { await openWhyBiographyIfAvailable(for: node) }
    }
}
