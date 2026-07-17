import SwiftUI
import AtlasCore

// Conteúdo do recibo — peel de AtlasCodeHealReceiptSheet (régua ≤100).
// Masthead/undo → +Chrome · Status → +Status.swift
// Undo footer → AtlasCodeHealReceiptSheet+UndoFooter.swift
// Steps → AtlasCodeHealReceiptSheet+StepsOrEmpty.swift

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    func receiptContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            healStatusLines
            receiptStepsOrEmpty
            receiptUndoFooter
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
    }
}
