import Foundation

// Confirm spoken — peel de AutonomosReasonSheet+A11y.

extension AutonomosReasonSheet {
    func spokenConfirmLabel(canSubmit: Bool) -> String {
        canSubmit
            ? "confirmar \(title.lowercased())"
            : "confirmar indisponível, preencha operador e motivo"
    }

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

    func spokenActorHint() -> String {
        "nome de quem autoriza a ação governada"
    }

    func spokenReasonHint() -> String {
        reasonOptional
            ? "motivo auditável opcional no ensaio"
            : "motivo auditável registrado no ledger"
    }
}
