import SwiftUI
import AtlasCore

// Incident card — peel de AutonomosTaskHealthSection incidentBody.

extension AutonomosTaskHealthSection {
    var incidentCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("INCIDENTE").font(AtlasFont.mono(10)).tracking(1.1)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text(health.incidents.flags.joined(separator: " · "))
                .font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            Text(health.operating.recommendedAction)
                .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosTaskHealthA11y.spokenIncident(health))
        .accessibilityIdentifier(A11yID.autonomosTaskHealthIncident)
    }
}
