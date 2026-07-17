import SwiftUI
import AtlasCore

// Graph-open delivered row — peel de AutonomosAreaDeliveredSection+Row.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredGraphRow(cycle: AtlasAutonomosCycle, index: Int, visible: Int) -> some View {
        if let repo = area.repositoryNames.first?.nonEmpty {
            deliveredGraphOpenButton(cycle: cycle, index: index, visible: visible, repo: repo)
        } else {
            deliveredRow(cycle)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: false, opensGraph: false))
                .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        }
    }
}
