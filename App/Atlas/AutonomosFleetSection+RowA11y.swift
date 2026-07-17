import SwiftUI
import AtlasCore

// Agent row a11y — peel de AutonomosFleetSection+Row.

extension View {
    func autonomosFleetAgentA11y(
        agent: AtlasAutonomosFleetAgent,
        index: Int,
        total: Int,
        compact: Bool,
        auditModeEnabled: Bool
    ) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AutonomosFleetSectionA11y.spokenAgent(
                    agent,
                    index: index,
                    total: total,
                    compact: compact,
                    auditModeEnabled: auditModeEnabled
                )
            )
            .accessibilityIdentifier(A11yID.autonomosFleetAgentRow(index))
    }
}
