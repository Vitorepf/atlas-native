import Foundation

// Autônomos reason/delivered A11yIDs — peel de A11yID+AutonomosArea.

extension A11yID {
    static let autonomosAreaDeliveredSection = "autonomos-area-delivered-section"
    static let autonomosAreaDeliveredSelf = "autonomos-area-delivered-self"
    static let autonomosAreaDeliveredEmpty = "autonomos-area-delivered-empty"
    static let autonomosAreaDeliveredRowPrefix = "autonomos-area-delivered-row-"
    static func autonomosAreaDeliveredRow(_ index: Int) -> String { autonomosAreaDeliveredRowPrefix + String(index) }
    static let autonomosAreaControls = "autonomos-area-controls"
    static let autonomosReasonSheet = "autonomos-reason-sheet"
    static let autonomosReasonActor = "autonomos-reason-actor"
    static let autonomosReasonField = "autonomos-reason-field"
    static let autonomosReasonSubmit = "autonomos-reason-submit"
    static let autonomosDetailClose = "autonomos-detail-close"
    static let autonomosDetailEmpty = "autonomos-detail-empty"

    static func autonomosDetailButton(_ key: String) -> String { autonomosDetailButtonPrefix + key }
}
