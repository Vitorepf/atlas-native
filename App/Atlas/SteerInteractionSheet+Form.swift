import SwiftUI
import AtlasCore

/// Form body — peel de SteerInteractionSheet (régua ≤100).
/// Instruction → SteerInteractionSheet+Instruction.swift
/// Header → SteerInteractionSheet+FormHeader.swift
/// Receipt → SteerInteractionSheet+FormReceipt.swift

extension SteerInteractionSheet {
    var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            formHeader
            instructionField
            formReceiptLine
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: matchedReceipt)
    }
}
