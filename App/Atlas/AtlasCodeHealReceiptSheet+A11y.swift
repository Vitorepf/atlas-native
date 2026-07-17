import Foundation
import AtlasCore

// Spoken labels — peel de AtlasCodeHealReceiptSheet (CICLO C residual honesty).
// Só fala passos reais do contrato heal; silêncio sem conclusão; veto só com healId.

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

    func spokenUndoButtonLabel() -> String {
        canUndo ? "desfazer cura com recibo" : "desfazer indisponível"
    }

    func spokenUndoButtonHint() -> String {
        canUndo
            ? "envia veto retroativo auditável para esta cura"
            : "prazo de veto encerrado ou recibo sem identificador"
    }
}
