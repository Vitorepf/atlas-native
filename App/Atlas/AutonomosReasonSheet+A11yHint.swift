import Foundation

// Sheet hint spoken — peel de AutonomosReasonSheet+A11y.

extension AutonomosReasonSheet {
    func spokenSheetHint() -> String {
        reasonOptional
            ? "motivo opcional no ensaio; o recibo entra na fila"
            : "motivo auditável obrigatório; o recibo entra na fila"
    }
}
