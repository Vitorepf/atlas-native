import Foundation

// Hints do formulário reason — peel de AutonomosReasonSheet+A11yConfirm.

extension AutonomosReasonSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza a ação governada"
    }

    func spokenReasonHint() -> String {
        reasonOptional
            ? "motivo auditável opcional no ensaio"
            : "motivo auditável registrado no ledger"
    }
}
