import Foundation
import AtlasCore

// Undo window gate — peel de AtlasCodeHealReceiptSheet+A11y.

extension AtlasCodeHealReceiptSheet {
    var undoExpiresAt: String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    var canUndo: Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt)
    }
}
