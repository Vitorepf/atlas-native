import Foundation

// Aggregate spoken — peel de AutonomosOperationDigest+A11y.
// SectionLead → AutonomosOperationDigest+A11yAggregate+SectionLead.swift

extension AutonomosOperationDigestA11y {
    static func spokenSection(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        incidentPresent: Bool,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> String {
        var parts = spokenSectionLeadParts(
            incidentPresent: incidentPresent,
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount
        )
        parts.append(contentsOf: spokenCounts(
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt,
            findingsByRisk: findingsByRisk
        ))
        return parts.joined(separator: ", ")
    }
}
