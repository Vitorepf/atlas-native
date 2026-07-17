import SwiftUI
import AtlasCore

// Conteúdo do recibo — peel de AtlasCodeHealReceiptSheet (régua ≤100).
// Masthead/undo → +Chrome · Status → +Status.swift

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

            if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt) {
                Text(note)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.codeHealUndoWindow)
                    .accessibilityLabel(spokenUndoWindowLabel(note))
            }
            if canUndo {
                undoButton
            }

            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
    }
}
