import Foundation

/// Spoken labels da folha de transferência — peel de AutonomosTransferSheet (CICLO C).
/// Confirmar → AutonomosTransferSheet+A11yConfirm.swift
/// Mission → AutonomosTransferSheet+A11yMission.swift
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
}
