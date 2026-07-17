import SwiftUI
import AtlasCore

// Graph-open button — peel de AutonomosAreaDeliveredSection+RowGraph.
// A11y → AutonomosAreaDeliveredSection+RowGraph+OpenButton+A11y.swift

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredGraphOpenButton(
        cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int,
        repo: String
    ) -> some View {
        deliveredGraphOpenA11y(
            Button {
                openCommit(cycle.mergeHash, repo: repo)
            } label: {
                deliveredRow(cycle, graphHint: true)
            }
            .buttonStyle(.plain),
            cycle: cycle,
            index: index,
            visible: visible
        )
    }
}
