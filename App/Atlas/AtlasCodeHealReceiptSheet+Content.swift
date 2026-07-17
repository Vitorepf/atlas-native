import SwiftUI
import AtlasCore

// Conteúdo do recibo — peel de AtlasCodeHealReceiptSheet (régua ≤100).
// Masthead/undo → +Chrome · Status → +Status.swift
// Undo footer → AtlasCodeHealReceiptSheet+UndoFooter.swift

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    func receiptContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            healStatusLines

            if heal.stepReceipts.isEmpty {
                Text("sem passos registrados no recibo")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel(spokenEmptyStepsLabel())
            } else {
                stepsBlock()
            }

            receiptUndoFooter

            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
    }
}
