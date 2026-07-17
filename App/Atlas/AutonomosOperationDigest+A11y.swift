import Foundation

/// Spoken labels do resumo da operação — peel de AutonomosOperationDigestSection (CICLO C).
/// Headlines → AutonomosOperationDigest+A11yHeadlines.swift
/// Quiet → AutonomosOperationDigest+A11yQuiet.swift
/// Counts → AutonomosOperationDigest+A11yCounts.swift

enum AutonomosOperationDigestA11y {
    static func spokenSection(
        deliveredTotal: Int,
        pendingCount: Int,
        inboxCount: Int,
        incidentPresent: Bool,
        oldestBacklogCreatedAt: Date?,
        findingsByRisk: [String: Int]
    ) -> String {
        var parts = spokenSectionLead(
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
