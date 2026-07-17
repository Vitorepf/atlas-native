import SwiftUI
import AtlasCore

// Phase ID canônico — peel de AutonomosLoadedSection+Receipts.

extension AutonomosLoadedSection {
    static func receiptPhaseID(for model: AutonomosModel) -> String {
        var parts: [String] = []
        if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
            parts.append("start:\(receipt.status):\(receipt.launch)")
        }
        if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
            parts.append("transfer:\(transfer.handoff.handoffId):\(transfer.handoff.status)")
        }
        if let receipt = model.lastControlReceipt {
            parts.append("control:\(receipt.action.rawValue):\(receipt.applied)")
        }
        if let error = model.controlError { parts.append("error:\(error)") }
        return parts.joined(separator: "|")
    }

    var receiptPhaseID: String { Self.receiptPhaseID(for: model) }
}
