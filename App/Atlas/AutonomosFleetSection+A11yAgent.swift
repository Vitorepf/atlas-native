import Foundation
import AtlasCore

// Agent spoken label — peel de AutonomosFleetSection+A11y.

extension AutonomosFleetSectionA11y {
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
