import SwiftUI
import AtlasCore

// Lista filtrada do grafo — peel de AtlasCodeView+Graph.
// Tail → AtlasCodeView+GraphListTail.swift

extension AtlasCodeView {
    func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        let filteredNodes = graphStateFilter.nodes(in: graph.nodes, model: model)
        let filterSilence = graphStateFilter != .all && filteredNodes.isEmpty
        let scroll = ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                statusCapsule
                    .padding(.bottom, 14)

                if !graph.worktrees.isEmpty {
                    worktreesSection(graph.worktrees)
                        .padding(.bottom, 14)
                }

                graphStateChips(graph, filterSilence: filterSilence)
                    .padding(.bottom, 10)

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

                graphListTail(graph: graph)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .padding(.bottom, 96)
        }
        .refreshable {
            await model.load()
            await mirrorModel.refresh()
        }
        return graphAccessibilityRotors(graph: graph, content: scroll)
    }
}
