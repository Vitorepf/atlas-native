import Foundation
import AtlasCore

/// Spoken labels da frota — peel de AutonomosFleetSection (CICLO C).
/// Details → AutonomosFleetSection+A11yDetails.swift

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
}
