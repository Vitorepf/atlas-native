import Foundation

/// Spoken labels da folha de transferência — peel de AutonomosTransferSheet (CICLO C).
/// Confirmar só com placement verificado + ator/motivo; alvo nunca inventado.

enum AutonomosTransferSheetA11y {
    static func spokenSheet(areaName: String, hasPlacement: Bool) -> String {
        var parts = ["transferir missão", areaName]
        if hasPlacement {
            parts.append("lock verificado")
        } else {
            parts.append("sem lock publicado")
        }
        return parts.joined(separator: ", ")
    }

    static let sheetHint = "transfere a missão só com lease vivo; o alvo aparece após target_claimed"

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
}
