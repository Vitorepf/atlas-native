import SwiftUI
import AtlasCore

// Incident copy stack — peel de AutonomosFleetTaskHealth+IncidentCard.

extension AutonomosTaskHealthSection {
    @ViewBuilder
    var incidentCardTexts: some View {
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
}
