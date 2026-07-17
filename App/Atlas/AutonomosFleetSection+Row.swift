import SwiftUI
import AtlasCore

// Agent row chrome — peel de AutonomosFleetSection.

extension AutonomosFleetSection {
    @ViewBuilder
    func agentRow(_ agent: AtlasAutonomosFleetAgent, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Circle().fill(agent.alive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                    .frame(width: 7, height: 7)
                Text(agent.label).font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer()
                Text(agent.status).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
            }
            if !compact {
                HStack(spacing: 10) {
                    if let up = agent.uptimeSeconds { AutonomosChrome.tag("↑ " + AutonomosChrome.uptime(up)) }
                    if !agent.pids.isEmpty { AutonomosChrome.tag("\(agent.pids.count) pid\(agent.pids.count == 1 ? "" : "s")") }
                    if let spent = agent.spentUsd { AutonomosChrome.tag(String(format: "US$ %.2f", spent)) }
                    AutonomosChrome.tag(agent.desired ? "desejado" : "não desejado")
                    AutonomosChrome.tag(agent.authorized ? "autorizado" : "não autorizado")
                }
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
