import SwiftUI
import AtlasCore

// Undo button — peel de AtlasCodeHealReceiptSheet+Chrome.
// Label → AtlasCodeHealReceiptSheet+UndoLabel.swift

extension AtlasCodeHealReceiptSheet {
    var undoButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onUndo()
            dismiss()
        } label: {
            undoButtonLabel
        }
        .buttonStyle(PressableScale())
        .transition(reduceMotion ? .identity : .opacity)
        .accessibilityIdentifier(A11yID.codeHealUndo)
        .accessibilityLabel(spokenUndoButtonLabel())
        .accessibilityHint(spokenUndoButtonHint())
    }
}
