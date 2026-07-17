import Foundation

// Backlog/findings append — peel de AutonomosOperationDigest+A11yCounts.

extension AutonomosOperationDigestA11y {
    static func spokenCountsBacklogFindings(
        _ parts: inout [String],
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) {
        parts.append(contentsOf: spokenBacklogParts(
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt
        ))
        parts.append(contentsOf: spokenCountFindings(findingsByRisk))
    }
}
