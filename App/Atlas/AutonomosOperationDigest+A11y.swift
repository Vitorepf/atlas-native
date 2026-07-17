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
        var parts = ["resumo da operação"]
        parts.append(incidentPresent ? "requer você, incidente aguarda decisão" : "por exceção")
        parts.append(spokenHeadline(delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
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
