import Foundation

// Autonomos fleet A11yIDs — peel de A11yID+Autonomos.

extension A11yID {
    static let autonomosFleetEmpty = "autonomos-fleet-empty"
    static let autonomosFleetQuiet = "autonomos-fleet-quiet"
    static let autonomosFleetSection = "autonomos-fleet-section"
    static let autonomosFleetAgentRowPrefix = "autonomos-fleet-agent-row-"
    static func autonomosFleetAgentRow(_ index: Int) -> String { autonomosFleetAgentRowPrefix + String(index) }
    static let autonomosFleetHistoryEmpty = "autonomos-fleet-history-empty"
    static let autonomosFleetHistorySection = "autonomos-fleet-history-section"
    static let autonomosFleetHistoryRowPrefix = "autonomos-fleet-history-row-"
    static func autonomosFleetHistoryRow(_ index: Int) -> String { autonomosFleetHistoryRowPrefix + String(index) }
}
