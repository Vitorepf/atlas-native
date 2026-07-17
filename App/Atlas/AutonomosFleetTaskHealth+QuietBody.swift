import SwiftUI
import AtlasCore

// Quiet body — peel de AutonomosFleetTaskHealth+Bodies.
// Copy → AutonomosFleetTaskHealth+QuietCopy.swift

extension AutonomosTaskHealthSection {
    var quietBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption("fila", role: .header)
            quietCopy
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AutonomosTaskHealthA11y.spokenQuiet(
                servableNow: health.tasks.servableNow,
                activeLeases: health.leases.active
            )
        )
        .accessibilityIdentifier(A11yID.autonomosTaskHealthQuiet)
    }
}
