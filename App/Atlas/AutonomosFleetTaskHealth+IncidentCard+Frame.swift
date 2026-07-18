import SwiftUI
import AtlasCore

// Incident card frame — peel de AutonomosFleetTaskHealth+IncidentCard.

extension AutonomosTaskHealthSection {
    var incidentCardFrame: some View {
        VStack(alignment: .leading, spacing: 6) {
            incidentCardTexts
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.domOperacional.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosTaskHealthA11y.spokenIncident(health))
        .accessibilityIdentifier(A11yID.autonomosTaskHealthIncident)
    }
}
