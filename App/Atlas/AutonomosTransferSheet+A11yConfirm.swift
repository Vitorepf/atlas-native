import Foundation

/// Confirm / cancel / target spoken — peel de AutonomosTransferSheet+A11y.

enum AutonomosTransferSheetA11yConfirm {
    static func spokenConfirm(canConfirm: Bool) -> String {
        canConfirm ? "confirmar transferência" : "confirmar indisponível"
    }

    static func spokenConfirmHint(canConfirm: Bool, hasPlacement: Bool) -> String {
        if canConfirm { return "envia handoff auditável com ator e motivo" }
        if !hasPlacement { return "exige lease vivo neste recorte" }
        return "preencha quem autoriza e o motivo auditável"
    }

    static let spokenCancel = "cancelar transferência"
    static let spokenTargetUnknown = "alvo desconhecido até target_claimed, a fila escolhe o worker"
    static let targetHint = "este app não promete host futuro"
    static let spokenNoLock = "nenhum lock publicado neste recorte, a transferência exige lease vivo"
}
