import SwiftUI
import AtlasCore

// Lista filtrada do grafo — peel de AtlasCodeView+Graph.
// Tail → AtlasCodeView+GraphListTail.swift
// Rows → AtlasCodeView+GraphListRows.swift

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

                graphCommitRows(filteredNodes)

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
