import SwiftUI
import AtlasCore

// Receipt line — peel de SteerInteractionSheet+Form.

extension SteerInteractionSheet {
    @ViewBuilder
    var formReceiptLine: some View {
        if let receipt = matchedReceipt {
            receiptLine(receipt)
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityIdentifier(A11yID.steerReceipt)
                .accessibilityLabel(spokenReceiptLabel(receipt))
        }
    }
}
