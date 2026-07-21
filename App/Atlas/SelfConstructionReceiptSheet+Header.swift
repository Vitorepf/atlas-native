import SwiftUI
import AtlasCore

// Seal header — peel de SelfConstructionReceiptSheet.

extension SelfConstructionReceiptSheet {
    var receiptSealHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.seal")
                .atlasSans(11, .bold)
                .accessibilityHidden(true)
            Text("RECIBO DE AUTO-CONSTRUÇÃO")
                .font(AtlasFont.mono(11))
                .tracking(1.0)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}
