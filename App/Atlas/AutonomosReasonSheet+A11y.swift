import Foundation

// Spoken labels — peel de AutonomosReasonSheet (CICLO C residual honesty).
// Confirmar só quando operador preenchido; motivo obrigatório exceto ensaio.
// Confirm → AutonomosReasonSheet+A11yConfirm.swift

extension AutonomosReasonSheet {
    func spokenSheetLabel() -> String {
        "confirmar ação governada, \(title.lowercased())"
    }

    func spokenSheetHint() -> String {
        reasonOptional
            ? "motivo opcional no ensaio; o recibo entra na fila"
            : "motivo auditável obrigatório; o recibo entra na fila"
    }
}
