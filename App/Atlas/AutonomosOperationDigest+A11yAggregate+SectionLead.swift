import Foundation

// Section lead bind — peel de AutonomosOperationDigest+A11yAggregate.

extension AutonomosOperationDigestA11y {
    static func spokenSectionLeadParts(
        incidentPresent: Bool,
        deliveredTotal: Int,
        pendingCount: Int
    ) -> [String] {
        spokenSectionLead(
            incidentPresent: incidentPresent,
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount
        )
    }
}
