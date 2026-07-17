import SwiftUI
import AtlasCore

// Transfer receipt — peel de AutonomosLoadedSection+ReceiptLines.

extension AutonomosRunReceiptLines {
    @ViewBuilder
    var transferReceiptLine: some View {
        if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
            AutonomosTransferStatus(transfer: transfer) {
                Task { await model.refreshTransferStatus() }
            }
            .transition(receiptTransition)
        }
    }
}
