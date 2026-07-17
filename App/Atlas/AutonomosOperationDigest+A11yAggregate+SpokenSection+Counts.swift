import Foundation

// Counts append — peel de AutonomosOperationDigest+A11yAggregate+SpokenSection.

extension AutonomosOperationDigestA11y {
    static func spokenSectionCountsParts(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> [String] {
        spokenCounts(
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt,
            findingsByRisk: findingsByRisk
        )
    }
}
