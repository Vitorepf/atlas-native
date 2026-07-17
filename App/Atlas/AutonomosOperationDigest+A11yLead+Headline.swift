import Foundation

// Headline phrase — peel de AutonomosOperationDigest+A11yLead.

extension AutonomosOperationDigestA11y {
    static func spokenHeadlinePhrase(
        deliveredTotal: Int,
        pendingCount: Int,
        incidentPresent: Bool
    ) -> String {
        spokenHeadline(delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent)
    }
}
