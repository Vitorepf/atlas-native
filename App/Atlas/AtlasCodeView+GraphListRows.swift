import SwiftUI
import AtlasCore

// Rows do grafo — peel de AtlasCodeView+GraphList.

extension AtlasCodeView {
    @ViewBuilder
    func graphCommitRows(_ filteredNodes: [AtlasCodeGraphNode]) -> some View {
        ForEach(Array(filteredNodes.enumerated()), id: \.element.id) { index, node in
            AtlasCodeCommitRow(
                node: node,
                state: model.state(for: node),
                ruleId: model.ruleId(for: node),
                trunk: model.violations?.trunk,
                isFirst: index == 0,
                isLast: index == filteredNodes.count - 1,
                isDimmed: !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
            ) {
                selectedNode = node
                Task { await provenanceModel.load(hash: node.hash) }
            } onLongPress: {
                guard visibleAnchors.contains(node.hash) else { return }
                Task { await openWhyBiographyIfAvailable(for: node) }
            }
            .accessibilityRotorEntry(id: node.id, in: graphRotor)
        }
    }
}
