import Foundation

/// Headlines spoken — peel de AutonomosOperationDigest+A11y.
/// Display → AutonomosOperationDigest+A11yDisplay.swift
/// Findings → AutonomosOperationDigest+A11yFindingsRisk.swift
/// Incident → AutonomosOperationDigest+A11yHeadlineIncident.swift
/// Queue → AutonomosOperationDigest+A11yHeadlineQueue.swift

extension AutonomosOperationDigestA11y {
    static func spokenHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return spokenHeadlineIncident() }
        return spokenHeadlineQueue(delivered: delivered, pending: pending)
    }
}
