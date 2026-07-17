import SwiftUI
import AtlasCore

// Compact metrics tags — peel de AutonomosFleetSection+Row.
// Audit → AutonomosFleetSection+RowAudit.swift

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
}
