import SwiftUI
import AtlasCore

// Incident / quiet bodies — peel de AutonomosTaskHealthSection.

extension AutonomosTaskHealthSection {
    var incidentBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("SAÚDE DA FILA")
            HStack(spacing: 8) {
                FleetMetric(value: "\(health.tasks.servableNow)", label: "servíveis agora")
                FleetMetric(value: "\(health.tasks.claimed)", label: "reivindicadas")
                FleetMetric(value: "\(health.tasks.blocked)", label: "bloqueadas")
                FleetMetric(value: "\(health.leases.active)", label: "leases ativos")
            }
            .accessibilityHidden(true)
            .animation(reduceMotion ? nil : .default, value: health.tasks.servableNow)
            .animation(reduceMotion ? nil : .default, value: health.tasks.claimed)
            HStack(spacing: 8) {
                FleetMetric(value: "\(health.tasks.completed)", label: "completas")
                FleetMetric(value: "\(health.tasks.recoverable)", label: "recuperáveis")
            }
            .accessibilityHidden(true)
            .animation(reduceMotion ? nil : .default, value: health.tasks.completed)
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

    var quietBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption("fila", role: .header)
            Text("estável · \(health.tasks.servableNow) servíveis · \(health.leases.active) leases")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
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
