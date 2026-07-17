import SwiftUI
import AtlasCore

// Worker gap — peel de ArenaRunSheet+ControlsCopy.

extension ArenaRunSheet {
    @ViewBuilder
    func receiptWorkerGapCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        if receipt.workerImplemented == false {
            Text("worker de medição ainda não implementado")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
