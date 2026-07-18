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
        receiptMultiEngineCopy
        receiptWorkerGapCopy(receipt)
    }

    /// Agregado do start multi-motor (goal 1) — só quando houve 2+ POSTs.
    @ViewBuilder
    var receiptMultiEngineCopy: some View {
        if model.lastStartEnginesCount > 1 {
            Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}
