import Foundation
import AtlasCore

// Contagens undo — peel de AtlasCodeHealReceiptSheet (CICLO C residual honesty).
// Undo/steps → AtlasCodeHealReceiptSheet+A11yUndo.swift
// Spoken → AtlasCodeHealReceiptSheet+A11ySpoken.swift

extension AtlasCodeHealReceiptSheet {
    var completedStepCount: Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    var hasCompletedHeal: Bool { completedStepCount > 0 }

    var undoExpiresAt: String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    var canUndo: Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt)
    }
}
