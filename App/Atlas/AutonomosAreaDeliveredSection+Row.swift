import SwiftUI
import AtlasCore

// Delivered row actions — peel de AutonomosAreaDeliveredSection.
// Visual → AutonomosAreaDeliveredSection+RowVisual.swift · Helpers → +Helpers.swift
// Graph → AutonomosAreaDeliveredSection+RowGraph.swift

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
        } else {
            deliveredGraphRow(cycle: cycle, index: index, visible: visible)
        }
    }
}
