import Foundation
import AtlasCore

/// Control receipt spoken — peel de AutonomosLoadedSection+A11y.
/// Action → AutonomosLoadedSection+A11yControlAction.swift
/// Error → AutonomosLoadedSection+A11yControlError.swift

enum AutonomosLoadedSectionA11yControl {
    static func spokenControlReceipt(_ receipt: AtlasAutonomosRunControlResponse) -> String {
        var parts = ["recibo de controle", AutonomosLoadedSectionA11yControlAction.spokenAction(receipt.action)]
        parts.append(receipt.applied ? "sinal aplicado" : "sinal registrado, ainda não aplicado")
        if receipt.isPaused { parts.append("pausa ativa") }
        if receipt.isKilled { parts.append("encerramento ativo") }
        let note = receipt.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty { parts.append(note) }
        return parts.joined(separator: ", ")
    }

    static func spokenControlError(_ message: String) -> String {
        AutonomosLoadedSectionA11yControlError.spokenControlError(message)
    }
}
