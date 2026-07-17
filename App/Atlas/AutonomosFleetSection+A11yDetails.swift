import Foundation
import AtlasCore

/// Operational spoken append — peel de AutonomosFleetSection+A11y.
/// Audit → AutonomosFleetSection+A11yAudit.swift

extension AutonomosFleetSectionA11y {
    static func appendOperationalDetails(
        _ parts: inout [String],
        agent: AtlasAutonomosFleetAgent
    ) {
        if let up = agent.uptimeSeconds { parts.append("ativo há \(AutonomosChrome.uptime(up))") }
        if !agent.pids.isEmpty {
            parts.append("\(agent.pids.count) processo\(agent.pids.count == 1 ? "" : "s")")
        }
        if let spent = agent.spentUsd { parts.append(String(format: "gasto US$ %.2f", spent)) }
        if !agent.desired { parts.append("não desejado") }
        if !agent.authorized { parts.append("não autorizado") }
    }
}
