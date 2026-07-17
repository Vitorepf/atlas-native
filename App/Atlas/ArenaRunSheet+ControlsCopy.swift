import SwiftUI
import AtlasCore

// Copy do recibo Arena — peel de ArenaRunSheet+Controls.

extension ArenaRunSheet {
    @ViewBuilder
    func receiptCardCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text("recibo \(receipt.receiptHash)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .accessibilityHidden(true)
        Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
            .font(.system(.callout, weight: .semibold))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
        if receipt.workerImplemented == false {
            Text("worker de medição ainda não implementado")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
