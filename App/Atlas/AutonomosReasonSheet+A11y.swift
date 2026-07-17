import Foundation

// Spoken labels — peel de AutonomosReasonSheet (CICLO C residual honesty).
// Confirmar só quando operador preenchido; motivo obrigatório exceto ensaio.

extension AutonomosReasonSheet {
    func spokenSheetLabel() -> String {
        "confirmar ação governada, \(title.lowercased())"
    }

    func spokenSheetHint() -> String {
        reasonOptional
            ? "motivo opcional no ensaio; o recibo entra na fila"
            : "motivo auditável obrigatório; o recibo entra na fila"
    }

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
