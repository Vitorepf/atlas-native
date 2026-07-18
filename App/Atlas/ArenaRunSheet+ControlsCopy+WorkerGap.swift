import SwiftUI
import AtlasCore

// Worker gap — peel de ArenaRunSheet+ControlsCopy.

extension ArenaRunSheet {
    @ViewBuilder
    func receiptWorkerGapCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        if receipt.workerImplemented == false {
            // false hoje = worker desligado no servidor (ATLAS_ARENA_WORKER_ENABLED).
            Text("worker de medição desligado no servidor — fila aguardando")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
