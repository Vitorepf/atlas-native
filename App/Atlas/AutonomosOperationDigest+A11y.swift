import Foundation

/// Spoken labels do resumo da operação — peel de AutonomosOperationDigestSection (CICLO C).
/// Headlines → AutonomosOperationDigest+A11yHeadlines.swift
/// Quiet → AutonomosOperationDigest+A11yQuiet.swift

enum AutonomosOperationDigestA11y {
    static func spokenSection(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        incidentPresent: Bool,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> String {
        var parts = ["resumo da operação"]
        parts.append(incidentPresent ? "requer você, incidente aguarda decisão" : "por exceção")
        parts.append(spokenHeadline(delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
        if deliveredTotal > 0 {
            parts.append("\(deliveredTotal) entregue\(deliveredTotal == 1 ? "" : "s") comprovada\(deliveredTotal == 1 ? "" : "s")")
        }
        if pendingCount > 0 {
            parts.append("\(pendingCount) tarefa\(pendingCount == 1 ? "" : "s") na fila")
        }
        if inboxCount > 0 {
            parts.append("\(inboxCount) decisão\(inboxCount == 1 ? "" : "ões") aguardando")
        }
        if let oldest = oldestBacklogCreatedAt {
            parts.append("item mais antigo \(AutonomosChrome.relativeAge(from: oldest))")
        }
        if !findingsByRisk.isEmpty {
            parts.append(spokenFindings(findingsByRisk))
        }
        return parts.joined(separator: ", ")
    }
}
