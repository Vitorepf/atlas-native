import SwiftUI
import AtlasCore

// Receipt status — peel de ArenaRunSheet+ControlsCopy.

extension ArenaRunSheet {
    @ViewBuilder
    func receiptStatusCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
            .font(.system(.callout, weight: .semibold))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}
