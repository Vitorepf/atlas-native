import Foundation

// Confirm hint — peel de AutonomosReasonSheet+A11yConfirm.

extension AutonomosReasonSheet {
    func spokenConfirmHint(canSubmit: Bool) -> String {
        if canSubmit {
            return reasonOptional
                ? "registra operador e motivo opcional no recibo auditável"
                : "registra operador e motivo obrigatório no recibo auditável"
        }
        return reasonOptional
            ? "informe quem autoriza; motivo é opcional no ensaio"
            : "informe quem autoriza e o motivo auditável"
    }
}
