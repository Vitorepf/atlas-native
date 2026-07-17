import SwiftUI
import AtlasCore

// Self-construction row — peel de AutonomosAreaDeliveredSection+Row.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredSelfRow(cycle: AtlasAutonomosCycle, index: Int, visible: Int) -> some View {
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
    }
}
