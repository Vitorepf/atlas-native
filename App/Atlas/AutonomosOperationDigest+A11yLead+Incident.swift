import Foundation

// Incident phrase — peel de AutonomosOperationDigest+A11yLead.

extension AutonomosOperationDigestA11y {
    static func spokenIncidentPhrase(incidentPresent: Bool) -> String {
        incidentPresent ? "requer você, incidente aguarda decisão" : "por exceção"
    }
}
