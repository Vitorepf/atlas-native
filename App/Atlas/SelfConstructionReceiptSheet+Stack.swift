import SwiftUI
import AtlasCore

// Title + stack body — peel de SelfConstructionReceiptSheet.
// Title → SelfConstructionReceiptSheet+Title.swift

extension SelfConstructionReceiptSheet {
    var receiptBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            receiptSealHeader
            receiptTitleBlock
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
