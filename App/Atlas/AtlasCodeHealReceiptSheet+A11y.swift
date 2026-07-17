import Foundation
import AtlasCore

// Spoken labels — peel de AtlasCodeHealReceiptSheet (CICLO C residual honesty).
// Undo/steps → AtlasCodeHealReceiptSheet+A11yUndo.swift

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

    func spokenSheetLabel() -> String {
        var parts = ["recibo de cura", heal.mode]
        if heal.stepReceipts.isEmpty {
            parts.append("sem passos no recibo")
        } else {
            parts.append("\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s")")
            parts.append("\(completedStepCount) concluído\(completedStepCount == 1 ? "" : "s")")
        }
        if let blocked = heal.blocked, !blocked.isEmpty {
            parts.append("bloqueado, \(blocked)")
        }
        return parts.joined(separator: ", ")
    }

    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }

    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }
}
