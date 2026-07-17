import Foundation

// Section lead — peel de AutonomosOperationDigest+A11yAggregate+SpokenSection.

extension AutonomosOperationDigestA11y {
    static func spokenSectionIncidentLead(
        incidentPresent: Bool,
        deliveredTotal: Int,
        pendingCount: Int
    ) -> [String] {
        spokenSectionLeadParts(
            incidentPresent: incidentPresent,
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount
        )
    }
}
