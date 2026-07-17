import SwiftUI
import AtlasCore

// Graph-open delivered row — peel de AutonomosAreaDeliveredSection+Row.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredGraphRow(cycle: AtlasAutonomosCycle, index: Int, visible: Int) -> some View {
        if let repo = area.repositoryNames.first?.nonEmpty {
            Button {
                openCommit(cycle.mergeHash, repo: repo)
            } label: {
                deliveredRow(cycle, graphHint: true)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: false, opensGraph: true))
            .accessibilityHint(AutonomosAreaDeliveredA11y.spokenRowHint(isSelf: false))
            .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        } else {
            deliveredRow(cycle)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: false, opensGraph: false))
                .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        }
    }
}
