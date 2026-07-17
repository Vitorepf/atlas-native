import Foundation

// Oldest backlog age — peel de AutonomosOperationDigest+A11yBacklog.

extension AutonomosOperationDigestA11y {
    static func spokenBacklogOldest(_ oldestBacklogCreatedAt: Date?) -> String? {
        guard let oldest = oldestBacklogCreatedAt else { return nil }
        return "item mais antigo \(AutonomosChrome.relativeAge(from: oldest))"
    }
}
