import Foundation

// Operation digest backlog parts — peel de AutonomosOperationDigest+A11yCounts.

extension AutonomosOperationDigestA11y {
    static func spokenBacklogParts(
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?
    ) -> [String] {
        var parts: [String] = []
        if pendingCount > 0 {
            parts.append("\(pendingCount) tarefa\(pendingCount == 1 ? "" : "s") na fila")
        }
        if inboxCount > 0 {
            parts.append("\(inboxCount) decisão\(inboxCount == 1 ? "" : "ões") aguardando")
        }
        if let oldest = oldestBacklogCreatedAt {
            parts.append("item mais antigo \(AutonomosChrome.relativeAge(from: oldest))")
        }
        return parts
    }
}
