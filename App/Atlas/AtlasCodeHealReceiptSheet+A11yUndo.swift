import Foundation
import AtlasCore

// Undo + step spoken — peel de AtlasCodeHealReceiptSheet+A11y.
// Button → AtlasCodeHealReceiptSheet+A11yUndoButton.swift

extension AtlasCodeHealReceiptSheet {
    func spokenStepsSummaryLabel() -> String {
        "\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s") no recibo"
    }

    func spokenStepLabel(_ receipt: AtlasCodeHealStepReceipt) -> String {
        let outcome = receipt.status == "completed" ? "concluído" : "falhou"
        var parts = ["passo \(receipt.step)", receipt.action, outcome]
        if !receipt.result.isEmpty { parts.append(receipt.result) }
        return parts.joined(separator: ", ")
    }

    func spokenUndoWindowLabel(_ note: String) -> String {
        "janela de veto, \(note)"
    }
}
