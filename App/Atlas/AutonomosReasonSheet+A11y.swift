import Foundation

// Spoken labels — peel de AutonomosReasonSheet (CICLO C residual honesty).
// Confirmar só quando operador preenchido; motivo obrigatório exceto ensaio.
// Confirm → AutonomosReasonSheet+A11yConfirm.swift
// Hint → AutonomosReasonSheet+A11yHint.swift

extension AutonomosReasonSheet {
    func spokenSheetLabel() -> String {
        "confirmar ação governada, \(title.lowercased())"
    }
}
