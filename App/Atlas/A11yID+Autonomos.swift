import Foundation

// Autônomos + Nightly + Self-receipt A11yIDs — peel de A11yID.swift (régua ≤100).

extension A11yID {
    static let autonomosAwaitingYou = "autonomos-awaiting-you"
    static let autonomosDetailSheet = "autonomos-detail-sheet"
    static let autonomosDetailButtonPrefix = "autonomos-detail-button-"
    static let autonomosFleetEmpty = "autonomos-fleet-empty"
    static let autonomosFleetQuiet = "autonomos-fleet-quiet"
    static let autonomosFleetHistoryEmpty = "autonomos-fleet-history-empty"
    static let autonomosFleetHistorySection = "autonomos-fleet-history-section"
    static let autonomosFleetHistoryRowPrefix = "autonomos-fleet-history-row-"
    static func autonomosFleetHistoryRow(_ index: Int) -> String { autonomosFleetHistoryRowPrefix + String(index) }
    static let autonomosDigestSection = "autonomos-digest-section"
    static let autonomosDigestEmpty = "autonomos-digest-empty"
    static let autonomosOperationDigest = "autonomos-operation-digest"
    static let autonomosOperationQuiet = "autonomos-operation-quiet"
    static let autonomosTransferSheet = "autonomos-transfer-sheet"
    static let autonomosTransferStatus = "autonomos-transfer-status"
    static let autonomosTransferRefresh = "autonomos-transfer-refresh"
    static let autonomosTransferActor = "autonomos-transfer-actor"
    static let autonomosTransferReason = "autonomos-transfer-reason"
    static let autonomosTransferSubmit = "autonomos-transfer-submit"
    static let autonomosLoadFailure = "autonomos-load-failure"
    static let autonomosRetry = "autonomos-retry"
    static let autonomosHeader = "autonomos-header"
    static let autonomosRefresh = "autonomos-refresh"
    static let autonomosAreaControls = "autonomos-area-controls"
    static let autonomosReasonSheet = "autonomos-reason-sheet"
    static let autonomosReasonActor = "autonomos-reason-actor"
    static let autonomosReasonField = "autonomos-reason-field"
    static let autonomosReasonSubmit = "autonomos-reason-submit"
    static let autonomosDetailClose = "autonomos-detail-close"
    static let autonomosDetailEmpty = "autonomos-detail-empty"

    static let nightlyProposalCard = "nightly-proposal-card"
    static let nightlyProposalAccept = "nightly-proposal-accept"
    static let nightlyProposalDismiss = "nightly-proposal-dismiss"
    static let nightlyProposalMute = "nightly-proposal-mute"

    static let selfReceiptSheet = "self-receipt-sheet"
    static let selfReceiptVeto = "self-receipt-veto"

    static func autonomosDetailButton(_ key: String) -> String { autonomosDetailButtonPrefix + key }
}
