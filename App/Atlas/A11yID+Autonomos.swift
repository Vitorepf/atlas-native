import Foundation

// Autônomos A11yIDs — peel de A11yID.swift (régua ≤100).
// Nightly/Self → A11yID+NightlySelf.swift · Area/Transfer → A11yID+AutonomosArea.swift

extension A11yID {
    static let autonomosScreen = "autonomos-screen"
    static let autonomosAwaitingYou = "autonomos-awaiting-you"
    static let autonomosDetailSheet = "autonomos-detail-sheet"
    static let autonomosDetailButtonPrefix = "autonomos-detail-button-"
    static let autonomosFleetEmpty = "autonomos-fleet-empty"
    static let autonomosFleetQuiet = "autonomos-fleet-quiet"
    static let autonomosFleetSection = "autonomos-fleet-section"
    static let autonomosFleetAgentRowPrefix = "autonomos-fleet-agent-row-"
    static func autonomosFleetAgentRow(_ index: Int) -> String { autonomosFleetAgentRowPrefix + String(index) }
    static let autonomosFleetHistoryEmpty = "autonomos-fleet-history-empty"
    static let autonomosFleetHistorySection = "autonomos-fleet-history-section"
    static let autonomosFleetHistoryRowPrefix = "autonomos-fleet-history-row-"
    static func autonomosFleetHistoryRow(_ index: Int) -> String { autonomosFleetHistoryRowPrefix + String(index) }
    static let autonomosDigestSection = "autonomos-digest-section"
    static let autonomosDigestEmpty = "autonomos-digest-empty"
    static let autonomosOperationDigest = "autonomos-operation-digest"
    static let autonomosOperationQuiet = "autonomos-operation-quiet"
}
