import SwiftUI
import AtlasCore

/// Form body — peel de SteerInteractionSheet (régua ≤100).
/// Instruction → SteerInteractionSheet+Instruction.swift
/// Header → SteerInteractionSheet+FormHeader.swift

extension SteerInteractionSheet {
    var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            formHeader
            instructionField
            if let receipt = matchedReceipt {
                receiptLine(receipt)
                    .transition(reduceMotion ? .identity : .opacity)
                    .accessibilityIdentifier(A11yID.steerReceipt)
                    .accessibilityLabel(spokenReceiptLabel(receipt))
            }
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: matchedReceipt)
    }
}
