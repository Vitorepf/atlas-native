import SwiftUI
import AtlasCore

// Self-construction title block — peel de SelfConstructionReceiptSheet+Stack.

extension SelfConstructionReceiptSheet {
    var receiptTitleBlock: some View {
        Text(receipt.title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}
