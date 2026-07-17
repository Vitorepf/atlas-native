import SwiftUI
import AtlasCore

// Graph-open a11y — peel de AutonomosAreaDeliveredSection+RowGraph+OpenButton.

extension AutonomosAreaDeliveredSection {
    func deliveredGraphOpenA11y<Content: View>(
        _ content: Content,
        cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int
    ) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(
                cycle, index: index, visible: visible, isSelf: false, opensGraph: true))
            .accessibilityHint(AutonomosAreaDeliveredA11y.spokenRowHint(isSelf: false))
            .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
    }
}
