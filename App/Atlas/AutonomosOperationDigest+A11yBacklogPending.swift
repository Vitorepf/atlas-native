import Foundation

// Pending backlog count — peel de AutonomosOperationDigest+A11yBacklog.

extension AutonomosOperationDigestA11y {
    static func spokenBacklogPending(_ pendingCount: Int) -> String? {
        guard pendingCount > 0 else { return nil }
        return "\(pendingCount) tarefa\(pendingCount == 1 ? "" : "s") na fila"
    }
}
