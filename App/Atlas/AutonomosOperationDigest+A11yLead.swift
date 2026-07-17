import Foundation

// Section lead spoken — peel de AutonomosOperationDigest+A11y.

extension AutonomosOperationDigestA11y {
    static func spokenSectionLead(
        incidentPresent: Bool,
        deliveredTotal: Int,
        pendingCount: Int
    ) -> [String] {
        var parts = ["resumo da operação"]
        parts.append(incidentPresent ? "requer você, incidente aguarda decisão" : "por exceção")
        parts.append(spokenHeadline(delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
        return parts
    }
}
