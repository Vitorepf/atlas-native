import SwiftUI
import AtlasCore

// Copy do recibo Arena — peel de ArenaRunSheet+Controls.
// Hash → ArenaRunSheet+ControlsCopy+ReceiptHash.swift
// Status → ArenaRunSheet+ControlsCopy+ReceiptStatus.swift
// Worker → ArenaRunSheet+ControlsCopy+WorkerGap.swift

extension ArenaRunSheet {
    @ViewBuilder
    func receiptCardCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        receiptHashCopy(receipt)
        receiptStatusCopy(receipt)
        receiptWorkerGapCopy(receipt)
    }
}
