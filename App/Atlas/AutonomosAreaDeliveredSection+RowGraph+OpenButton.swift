import SwiftUI
import AtlasCore

// Graph-open button — peel de AutonomosAreaDeliveredSection+RowGraph.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredGraphOpenButton(
        cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int,
        repo: String
    ) -> some View {
        Button {
            openCommit(cycle.mergeHash, repo: repo)
        } label: {
            deliveredRow(cycle, graphHint: true)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(
            cycle, index: index, visible: visible, isSelf: false, opensGraph: true))
        .accessibilityHint(AutonomosAreaDeliveredA11y.spokenRowHint(isSelf: false))
        .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
    }
}
