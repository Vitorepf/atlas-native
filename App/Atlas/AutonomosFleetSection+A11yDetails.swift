import Foundation
import AtlasCore

/// Operational/audit spoken append — peel de AutonomosFleetSection+A11y.

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

    static func appendAuditDetails(
        _ parts: inout [String],
        agent: AtlasAutonomosFleetAgent
    ) {
        parts.append("conta \(agent.account)")
        parts.append(agent.kind)
        if let ttl = agent.ttlRemainingSeconds { parts.append("ttl \(ttl) segundos") }
        if let budget = agent.budgetLimitUsd { parts.append(String(format: "limite US$ %.2f", budget)) }
        if let target = agent.targetRef?.nonEmpty { parts.append("alvo \(target)") }
        if let reason = agent.reason?.nonEmpty { parts.append(reason) }
    }
}
