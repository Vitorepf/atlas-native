import SwiftUI
import AtlasCore

// Linhas de recibo — peel de AutonomosLoadedSection+Receipts (CICLO D: um só phase ID).
// Transition → AutonomosLoadedSection+ReceiptTransition.swift

struct AutonomosRunReceiptLines: View {
    let model: AutonomosModel
    let reduceMotion: Bool

    var body: some View {
        Group {
            if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
                AutonomosInfoLine(
                    "Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.",
                    spokenLabel: AutonomosLoadedSectionA11y.spokenStartRunEnqueued(receipt),
                    identifier: A11yID.autonomosStartRunReceipt
                )
                .transition(receiptTransition)
            }
            if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
                AutonomosTransferStatus(transfer: transfer) {
                    Task { await model.refreshTransferStatus() }
                }
                .transition(receiptTransition)
            }
            if let receipt = model.lastControlReceipt {
                AutonomosControlReceiptLine(receipt: receipt)
                    .transition(receiptTransition)
            }
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: AutonomosLoadedSection.receiptPhaseID(for: model))
    }
}
