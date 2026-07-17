import Foundation

// Autônomos transfer/area A11yIDs — peel de A11yID+Autonomos.

extension A11yID {
    static let autonomosTransferSheet = "autonomos-transfer-sheet"
    static let autonomosTransferStatus = "autonomos-transfer-status"
    static let autonomosTaskHealthQuiet = "autonomos-task-health-quiet"
    static let autonomosTaskHealthIncident = "autonomos-task-health-incident"
    static let autonomosTransferRefresh = "autonomos-transfer-refresh"
    static let autonomosTransferActor = "autonomos-transfer-actor"
    static let autonomosTransferReason = "autonomos-transfer-reason"
    static let autonomosTransferSubmit = "autonomos-transfer-submit"
    static let autonomosLoadFailure = "autonomos-load-failure"
    static let autonomosRetry = "autonomos-retry"
    static let autonomosHeader = "autonomos-header"
    static let autonomosBack = "autonomos-back"
    static let autonomosRefresh = "autonomos-refresh"
    static let autonomosStartRunReceipt = "autonomos-start-run-receipt"
    static let autonomosControlReceipt = "autonomos-control-receipt"
    static let autonomosControlError = "autonomos-control-error"
    static let autonomosAreaPicker = "autonomos-area-picker"
    static let autonomosAreaPickerRowPrefix = "autonomos-area-picker-row-"
    static func autonomosAreaPickerRow(_ index: Int) -> String { autonomosAreaPickerRowPrefix + String(index) }
    static let autonomosAreaDetailSection = "autonomos-area-detail-section"
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
