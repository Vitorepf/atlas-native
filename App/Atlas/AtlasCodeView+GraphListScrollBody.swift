import SwiftUI
import AtlasCore

// Graph list scroll body — peel de AtlasCodeView+GraphListScroll.

extension AtlasCodeView {
    @ViewBuilder
    func graphListScrollBody(
        graph: AtlasCodeGraphResponse,
        filteredNodes: [AtlasCodeGraphNode],
        filterSilence: Bool
    ) -> some View {
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
}
