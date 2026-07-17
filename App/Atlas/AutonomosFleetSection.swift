import SwiftUI
import AtlasCore

/// Frota global — agentes reais, saúde da fila, histórico e handoff (C13).
struct AutonomosFleetSummary: View {
    let fleet: AtlasAutonomosFleetResponse

    var body: some View {
        HStack(spacing: 8) {
            FleetMetric(value: "\(fleet.agents.count)", label: "agentes registrados")
            FleetMetric(value: "\(fleet.agents.filter(\.alive).count)", label: "vivos agora")
            FleetMetric(value: "\(fleet.activeCount)", label: "ativos")
        }
    }
}

struct AutonomosFleetSection: View {
    let fleet: AtlasAutonomosFleetResponse
    var auditModeEnabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("FROTA GLOBAL")
            ForEach(fleet.agents) { agent in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Circle().fill(agent.alive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                            .frame(width: 7, height: 7)
                        Text(agent.label).font(.system(.footnote, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Spacer()
                        Text(agent.status).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    HStack(spacing: 10) {
                        if let up = agent.uptimeSeconds { AutonomosChrome.tag("↑ " + AutonomosChrome.uptime(up)) }
                        if !agent.pids.isEmpty { AutonomosChrome.tag("\(agent.pids.count) pid\(agent.pids.count == 1 ? "" : "s")") }
                        if let spent = agent.spentUsd { AutonomosChrome.tag(String(format: "US$ %.2f", spent)) }
                        AutonomosChrome.tag(agent.desired ? "desejado" : "não desejado")
                        AutonomosChrome.tag(agent.authorized ? "autorizado" : "não autorizado")
                    }
                    if auditModeEnabled {
                        HStack(spacing: 6) {
                            AutonomosChrome.tag(agent.account)
                            AutonomosChrome.tag(agent.kind)
                            if let ttl = agent.ttlRemainingSeconds { AutonomosChrome.tag("ttl \(ttl)s") }
                            if let budget = agent.budgetLimitUsd { AutonomosChrome.tag(String(format: "limite %.2f", budget)) }
                            if let target = agent.targetRef?.nonEmpty { AutonomosChrome.tag(target) }
                        }
                        if let reason = agent.reason?.nonEmpty {
                            Text(reason)
                                .font(.caption2)
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(12)
                .atlasCard(cornerRadius: 12)
            }
        }
    }
}

/// C13: saúde da fila do músculo externo — contagens verificáveis, nunca
/// "plano/progresso"; alerta só quando o servidor declara incidente.
struct AutonomosTaskHealthSection: View {
    let health: AtlasAutonomosTaskHealthResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            if health.incidents.present {
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
            }
        }
    }
}

struct AutonomosFleetHistorySection: View {
    let history: AtlasAutonomosFleetHistoryResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // A legenda conta o total: mostrar 6 de N sem dizer N faz o operador
            // ler "6" como "tudo". Nada cortado em silêncio.
            AutonomosChrome.sectionCaption(history.events.count > 6
                           ? "HISTÓRICO DA FROTA · 6 DE \(history.events.count)"
                           : "HISTÓRICO DA FROTA")
            ForEach(Array(history.events.prefix(6).enumerated()), id: \.element.id) { index, event in
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.35))
                            .frame(width: 7, height: 7)
                            .padding(.top, 5)
                        if index < min(history.events.count, 6) - 1 {
                            Rectangle()
                                .fill(AtlasTheme.accent.opacity(0.18))
                                .frame(width: 1.5, height: 34)
                        }
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.event)
                            .font(.system(.caption, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        HStack(spacing: 6) {
                            AutonomosChrome.tag(event.agentKey)
                            if let by = event.by?.nonEmpty { AutonomosChrome.tag(by) }
                            if let account = event.account?.nonEmpty { AutonomosChrome.tag(account) }
                            if let pid = event.pid { AutonomosChrome.tag("pid \(pid)") }
                            if let duration = event.durationSeconds { AutonomosChrome.tag(AutonomosChrome.uptime(duration)) }
                        }
                        if let reason = event.reason?.nonEmpty {
                            Text(reason)
                                .font(.caption2)
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .lineLimit(2)
                        }
                        Text(event.at)
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

/// C13: estados do handoff LITERAIS; host alvo só depois de target_claimed.
struct AutonomosTransferStatus: View {
    let transfer: AtlasAutonomosTransferResponse
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(transfer.handoff.status)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            if let note = transfer.note {
                Text(note).font(.caption).foregroundStyle(AtlasTheme.textSecondary).lineLimit(2)
            }
            Spacer()
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise").font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
