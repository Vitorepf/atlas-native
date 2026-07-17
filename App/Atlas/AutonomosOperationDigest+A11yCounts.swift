import Foundation

// Operation digest counts spoken — peel de AutonomosOperationDigest+A11y.
// Findings → AutonomosOperationDigest+A11yFindings.swift
// Backlog → AutonomosOperationDigest+A11yBacklog.swift
// Delivered → AutonomosOperationDigest+A11yDelivered.swift
// Delivered append → AutonomosOperationDigest+A11yCounts+Delivered.swift
// BacklogFindings → AutonomosOperationDigest+A11yCounts+BacklogFindings.swift

extension AutonomosOperationDigestA11y {
    static func spokenCounts(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> [String] {
        var parts: [String] = []
        spokenCountsDelivered(&parts, deliveredTotal: deliveredTotal)
        spokenCountsBacklogFindings(
            &parts,
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt,
            findingsByRisk: findingsByRisk
        )
        return parts
    }
}
