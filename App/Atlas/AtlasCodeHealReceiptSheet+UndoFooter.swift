import SwiftUI
import AtlasCore

// Heal receipt undo footer — peel de AtlasCodeHealReceiptSheet+Content.

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    var receiptUndoFooter: some View {
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
    }
}
