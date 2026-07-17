import SwiftUI
import AtlasCore

// Linhas de recibo — peel de AutonomosLoadedSection+Receipts (CICLO D: um só phase ID).
// Transition → AutonomosLoadedSection+ReceiptTransition.swift
// Start → AutonomosLoadedSection+ReceiptStart.swift

struct AutonomosRunReceiptLines: View {
    let model: AutonomosModel
    let reduceMotion: Bool

    var body: some View {
        Group {
            startRunReceiptLine
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
