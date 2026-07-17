import SwiftUI
import AtlasCore

// Spoken label — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    func digestSignalSpoken(_ view: some View) -> some View {
        view
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosOperationDigestA11y.spokenSection(
                deliveredTotal: deliveredTotal,
                pendingCount: pendingCount,
                inboxCount: inboxCount,
                incidentPresent: incidentPresent,
                oldestBacklogCreatedAt: oldestBacklogCreatedAt,
                findingsByRisk: findingsByRisk
            ))
    }
}
