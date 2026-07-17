import Foundation

// Confirm label — peel de AutonomosReasonSheet+A11yConfirm.

extension AutonomosReasonSheet {
    func spokenConfirmLabel(canSubmit: Bool) -> String {
        canSubmit
            ? "confirmar \(title.lowercased())"
            : "confirmar indisponível, preencha operador e motivo"
    }
}
