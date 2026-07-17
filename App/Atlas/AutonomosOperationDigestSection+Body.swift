import SwiftUI
import AtlasCore

// Corpo com sinal publicado — peel de AutonomosOperationDigestSection.
// Quiet → +Quiet · Meta → +SignalMeta
// Chrome → AutonomosOperationDigestSection+BodyChrome.swift
// Stack → AutonomosOperationDigestSection+BodyStack.swift

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalBody: some View {
        digestSignalChrome {
            digestSignalStack
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosOperationDigestA11y.spokenSection(
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            incidentPresent: incidentPresent,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt,
            findingsByRisk: findingsByRisk
        ))
        .accessibilityIdentifier(A11yID.autonomosOperationDigest)
    }
}
