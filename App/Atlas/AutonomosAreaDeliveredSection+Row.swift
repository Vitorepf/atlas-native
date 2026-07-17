import SwiftUI
import AtlasCore

// Delivered row actions — peel de AutonomosAreaDeliveredSection.
// Visual → AutonomosAreaDeliveredSection+RowVisual.swift · Helpers → +Helpers.swift

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredCycleRow(cycle: AtlasAutonomosCycle, index: Int, visible: Int, isSelf: Bool) -> some View {
        if isSelf {
            Button {
                onSelfConstructionReceipt(SelfConstructionReceipt(cycle: cycle, finding: selfConstructionFinding))
            } label: {
                deliveredRow(cycle)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: true, opensGraph: false))
            .accessibilityHint(AutonomosAreaDeliveredA11y.spokenRowHint(isSelf: true))
            .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        } else if let repo = area.repositoryNames.first?.nonEmpty {
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
