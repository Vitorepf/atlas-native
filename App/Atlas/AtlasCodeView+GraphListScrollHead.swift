import SwiftUI
import AtlasCore

// Graph list scroll head — peel de AtlasCodeView+GraphListScrollBody.

extension AtlasCodeView {
    @ViewBuilder
    func graphListScrollHead(
        graph: AtlasCodeGraphResponse,
        filterSilence: Bool
    ) -> some View {
        statusCapsule
            .padding(.bottom, 14)

        if !graph.worktrees.isEmpty {
            worktreesSection(graph.worktrees)
                .padding(.bottom, 14)
        }

        graphStateChips(graph, filterSilence: filterSilence)
            .padding(.bottom, 10)
    }
}
