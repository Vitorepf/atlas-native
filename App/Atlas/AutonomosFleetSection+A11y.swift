import Foundation
import AtlasCore

/// Spoken labels da frota — peel de AutonomosFleetSection (CICLO C).
/// Quiet = uma linha; detalhe falado só com campos publicados ou exceção.

enum AutonomosFleetSectionA11y {
    static func spokenSection(
        agentCount: Int,
        activeCount: Int,
        incidentPresent: Bool,
        isQuiet: Bool
    ) -> String {
        var parts = [incidentPresent ? "frota requer atenção" : "frota"]
        parts.append("\(agentCount) agente\(agentCount == 1 ? "" : "s")")
        parts.append("\(activeCount) ativo\(activeCount == 1 ? "" : "s")")
        if isQuiet { parts.append("todos vivos, desejados e autorizados") }
        return parts.joined(separator: ", ")
    }

    static func spokenAgent(
        _ agent: AtlasAutonomosFleetAgent,
        index: Int,
        total: Int,
        compact: Bool,
        auditModeEnabled: Bool
    ) -> String {
        var parts = ["agente \(index + 1) de \(total)", agent.label]
        parts.append(agent.alive ? "vivo" : "inativo")
        let status = agent.status.trimmingCharacters(in: .whitespacesAndNewlines)
        if !status.isEmpty { parts.append(status) }
        if !compact || AutonomosFleetHealth.agentNeedsAttention(agent) {
            appendOperationalDetails(&parts, agent: agent)
        }
        if auditModeEnabled { appendAuditDetails(&parts, agent: agent) }
        return parts.joined(separator: ", ")
    }

    private static func appendOperationalDetails(
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

    private static func appendAuditDetails(
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
