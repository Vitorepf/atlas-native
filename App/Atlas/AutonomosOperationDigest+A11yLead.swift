import Foundation

// Section lead spoken — peel de AutonomosOperationDigest+A11y.
// Incident → AutonomosOperationDigest+A11yLead+Incident.swift
// Headline → AutonomosOperationDigest+A11yLead+Headline.swift

extension AutonomosOperationDigestA11y {
    static func spokenSectionLead(
        incidentPresent: Bool,
        deliveredTotal: Int,
        pendingCount: Int
    ) -> [String] {
        var parts = ["resumo da operação"]
        parts.append(spokenIncidentPhrase(incidentPresent: incidentPresent))
        parts.append(spokenHeadlinePhrase(
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount,
            incidentPresent: incidentPresent
        ))
        return parts
    }
}
