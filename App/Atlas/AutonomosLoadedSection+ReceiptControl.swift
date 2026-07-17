import SwiftUI
import AtlasCore

// Control receipt line — peel de AutonomosLoadedSection+ReceiptLines.

extension AutonomosRunReceiptLines {
    @ViewBuilder
    var controlReceiptLine: some View {
        if let receipt = model.lastControlReceipt {
            AutonomosControlReceiptLine(receipt: receipt)
                .transition(receiptTransition)
        }
    }
}
