import SwiftUI
import AtlasCore

// Fleet a11y chrome — peel de AutonomosFleetSection.

extension AutonomosFleetSection {
    func fleetA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                AutonomosFleetSectionA11y.spokenSection(
                    agentCount: fleet.agents.count,
                    activeCount: fleet.activeCount,
                    incidentPresent: incidentPresent,
                    isQuiet: isQuiet && !auditModeEnabled
                )
            )
            .accessibilityIdentifier(A11yID.autonomosFleetSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isQuiet)
    }
}
