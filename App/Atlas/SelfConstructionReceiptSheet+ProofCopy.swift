import SwiftUI
import AtlasCore

// Proof copy — peel de SelfConstructionReceiptSheet+Body.

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofCopyBlock: some View {
        Text(receipt.proofLine)
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textPrimary)
            .textSelection(.enabled)
            .accessibilityHidden(true)
    }
}
