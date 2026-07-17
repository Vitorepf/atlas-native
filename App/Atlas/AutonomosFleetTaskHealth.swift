import SwiftUI
import AtlasCore

/// C13: saúde da fila do músculo externo — contagens verificáveis, nunca
/// "plano/progresso"; saudável = uma linha quieta; alerta só com incidente.
struct AutonomosTaskHealthSection: View {
    let health: AtlasAutonomosTaskHealthResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if health.incidents.present {
                AutonomosChrome.sectionCaption("SAÚDE DA FILA")
                HStack(spacing: 8) {
                    FleetMetric(value: "\(health.tasks.servableNow)", label: "servíveis agora")
                    FleetMetric(value: "\(health.tasks.claimed)", label: "reivindicadas")
                    FleetMetric(value: "\(health.tasks.blocked)", label: "bloqueadas")
                    FleetMetric(value: "\(health.leases.active)", label: "leases ativos")
                }
                HStack(spacing: 8) {
                    FleetMetric(value: "\(health.tasks.completed)", label: "completas")
                    FleetMetric(value: "\(health.tasks.recoverable)", label: "recuperáveis")
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("INCIDENTE").font(AtlasFont.mono(10)).tracking(1.1)
                        .foregroundStyle(AtlasTheme.domOperacional)
                    Text(health.incidents.flags.joined(separator: " · "))
                        .font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                    Text(health.operating.recommendedAction)
                        .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
            } else {
                // Silêncio quando saudável: sem grade de métricas, sem "SAÚDE".
                AutonomosChrome.sectionCaption("fila")
                Text("estável · \(health.tasks.servableNow) servíveis · \(health.leases.active) leases")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("fila estável, \(health.tasks.servableNow) servíveis, \(health.leases.active) leases")
            }
        }
    }
}
