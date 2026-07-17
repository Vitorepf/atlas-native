import Foundation

// Operation digest counts spoken — peel de AutonomosOperationDigest+A11y.
// Findings → AutonomosOperationDigest+A11yFindings.swift
// Backlog → AutonomosOperationDigest+A11yBacklog.swift
// Delivered → AutonomosOperationDigest+A11yDelivered.swift

extension AutonomosOperationDigestA11y {
    static func spokenCounts(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> [String] {
        var parts: [String] = []
        if let delivered = spokenDeliveredCount(deliveredTotal) {
            parts.append(delivered)
        }
        parts.append(contentsOf: spokenBacklogParts(
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt
        ))
        parts.append(contentsOf: spokenCountFindings(findingsByRisk))
        return parts
    }
}
