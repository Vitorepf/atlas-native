import SwiftUI
import AtlasCore

// Title + stack body — peel de SelfConstructionReceiptSheet.

extension SelfConstructionReceiptSheet {
    var receiptBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            receiptSealHeader

            Text(receipt.title)
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            ruleBlock
            proofBlock
            revertQueueBanner
            vetoSection
            humanSilenceLine

            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: revertReceipt != nil)
    }
}
