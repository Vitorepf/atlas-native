import SwiftUI
import AtlasCore

/// C13: saúde da fila do músculo externo — contagens verificáveis, nunca
/// "plano/progresso"; saudável = uma linha quieta; alerta só com incidente.
struct AutonomosTaskHealthSection: View {
    let health: AtlasAutonomosTaskHealthResponse
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if health.incidents.present {
                AutonomosChrome.sectionCaption("SAÚDE DA FILA")
                    .accessibilityHidden(true)
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
            } else {
                // Silêncio quando saudável: sem grade de métricas, sem "SAÚDE".
                VStack(alignment: .leading, spacing: 6) {
                    AutonomosChrome.sectionCaption("fila")
                        .accessibilityAddTraits(.isHeader)
                    Text("estável · \(health.tasks.servableNow) servíveis · \(health.leases.active) leases")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    AutonomosTaskHealthA11y.spokenQuiet(
                        servableNow: health.tasks.servableNow,
                        activeLeases: health.leases.active
                    )
                )
                .accessibilityIdentifier(A11yID.autonomosTaskHealthQuiet)
            }
        }
    }
}
