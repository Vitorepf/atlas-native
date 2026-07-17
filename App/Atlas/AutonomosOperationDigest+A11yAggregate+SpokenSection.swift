import Foundation

// spokenSection assembly — peel de AutonomosOperationDigest+A11yAggregate.
// Lead → AutonomosOperationDigest+A11yAggregate+SpokenSection+Lead.swift
// Counts → AutonomosOperationDigest+A11yAggregate+SpokenSection+Counts.swift

extension AutonomosOperationDigestA11y {
    static func spokenSection(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        incidentPresent: Bool,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> String {
        var parts = spokenSectionIncidentLead(
            incidentPresent: incidentPresent,
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount
        )
        parts.append(contentsOf: spokenSectionCountsParts(
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt,
            findingsByRisk: findingsByRisk
        ))
        return parts.joined(separator: ", ")
    }
}
