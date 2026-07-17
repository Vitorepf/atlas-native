import SwiftUI
import AtlasCore

// Compact metrics + audit tags — peel de AutonomosFleetSection+Row.

extension AutonomosFleetSection {
    @ViewBuilder
    func agentCompactTags(_ agent: AtlasAutonomosFleetAgent, compact: Bool) -> some View {
        if !compact {
            HStack(spacing: 10) {
                if let up = agent.uptimeSeconds { AutonomosChrome.tag("↑ " + AutonomosChrome.uptime(up)) }
                if !agent.pids.isEmpty { AutonomosChrome.tag("\(agent.pids.count) pid\(agent.pids.count == 1 ? "" : "s")") }
                if let spent = agent.spentUsd { AutonomosChrome.tag(String(format: "US$ %.2f", spent)) }
                AutonomosChrome.tag(agent.desired ? "desejado" : "não desejado")
                AutonomosChrome.tag(agent.authorized ? "autorizado" : "não autorizado")
            }
            .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func agentAuditTags(_ agent: AtlasAutonomosFleetAgent) -> some View {
        if auditModeEnabled {
            HStack(spacing: 6) {
                AutonomosChrome.tag(agent.account)
                AutonomosChrome.tag(agent.kind)
                if let ttl = agent.ttlRemainingSeconds { AutonomosChrome.tag("ttl \(ttl)s") }
                if let budget = agent.budgetLimitUsd { AutonomosChrome.tag(String(format: "limite %.2f", budget)) }
                if let target = agent.targetRef?.nonEmpty { AutonomosChrome.tag(target) }
            }
            .accessibilityHidden(true)
            if let reason = agent.reason?.nonEmpty {
                Text(reason)
                    .font(.caption2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
        }
    }
}
