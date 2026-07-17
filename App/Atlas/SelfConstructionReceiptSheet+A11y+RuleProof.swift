import Foundation

// Rule + proof spoken — peel de SelfConstructionReceiptSheet+A11y.

extension SelfConstructionReceiptSheet {
    func spokenRuleLabel() -> String {
        "regra citada, \(receipt.ruleLabel)"
    }

    func spokenProofLabel() -> String {
        "prova, \(receipt.proofLine)"
    }
}
