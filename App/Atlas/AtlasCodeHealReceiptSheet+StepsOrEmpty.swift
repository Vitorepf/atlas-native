import SwiftUI
import AtlasCore

// Empty steps — peel de AtlasCodeHealReceiptSheet+Content.

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    var receiptStepsOrEmpty: some View {
        if heal.stepReceipts.isEmpty {
            Text("sem passos registrados no recibo")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenEmptyStepsLabel())
        } else {
            stepsBlock()
        }
    }
}
