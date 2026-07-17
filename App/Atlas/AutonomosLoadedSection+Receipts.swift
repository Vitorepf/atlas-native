import SwiftUI
import AtlasCore

// Run receipts — peel de AutonomosLoadedSection.

extension AutonomosLoadedSection {
    @ViewBuilder
    var runReceiptLines: some View {
        if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
            AutonomosInfoLine("Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.")
        }
        if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
            AutonomosTransferStatus(transfer: transfer) {
                Task { await model.refreshTransferStatus() }
            }
        }
        if let receipt = model.lastControlReceipt {
            AutonomosControlReceiptLine(receipt: receipt)
        }
    }
}
