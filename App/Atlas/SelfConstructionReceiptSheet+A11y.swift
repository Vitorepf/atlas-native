import Foundation

// Spoken labels — peel de SelfConstructionReceiptSheet (CICLO C residual honesty).
// Veto → SelfConstructionReceiptSheet+VetoA11y.swift
// Silence → SelfConstructionReceiptSheet+A11ySilence.swift

extension SelfConstructionReceiptSheet {
    func spokenSheetLabel() -> String {
        var parts = ["recibo de auto-construção", "ciclo \(receipt.cycle.cycleIndex)"]
        parts.append(receipt.hasMergeProof ? "merge comprovado no ledger" : "sem merge comprovado")
        return parts.joined(separator: ", ")
    }

    func spokenRuleLabel() -> String {
        "regra citada, \(receipt.ruleLabel)"
    }

    func spokenProofLabel() -> String {
        "prova, \(receipt.proofLine)"
    }
}
