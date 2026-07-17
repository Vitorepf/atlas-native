import Foundation

// Veto field hints — peel de SelfConstructionReceiptSheet+VetoA11y.

extension SelfConstructionReceiptSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza o veto retroativo"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}
