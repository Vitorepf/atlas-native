import SwiftUI
import AtlasCore

// Undo button label — peel de AtlasCodeHealReceiptSheet+Undo.

extension AtlasCodeHealReceiptSheet {
    var undoButtonLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .atlasSans(14, .medium)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .foregroundStyle(AtlasTheme.textSecondary)
        .atlasCard(cornerRadius: 13)
    }
}
