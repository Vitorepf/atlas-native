import Foundation

// Operation digest counts spoken — peel de AutonomosOperationDigest+A11y.

extension AutonomosOperationDigestA11y {
    static func spokenCounts(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> [String] {
        var parts: [String] = []
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
        return parts
    }
}
