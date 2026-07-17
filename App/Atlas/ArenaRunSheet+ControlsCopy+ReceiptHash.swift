import SwiftUI
import AtlasCore

// Receipt hash — peel de ArenaRunSheet+ControlsCopy.

extension ArenaRunSheet {
    @ViewBuilder
    func receiptHashCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text("recibo \(receipt.receiptHash)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .accessibilityHidden(true)
    }
}
