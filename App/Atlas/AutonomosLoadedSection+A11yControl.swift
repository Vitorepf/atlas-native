import Foundation
import AtlasCore

/// Control receipt / error spoken — peel de AutonomosLoadedSection+A11y.

enum AutonomosLoadedSectionA11yControl {
    static func spokenControlReceipt(_ receipt: AtlasAutonomosRunControlResponse) -> String {
        var parts = ["recibo de controle", spokenAction(receipt.action)]
        parts.append(receipt.applied ? "sinal aplicado" : "sinal registrado, ainda não aplicado")
        if receipt.isPaused { parts.append("pausa ativa") }
        if receipt.isKilled { parts.append("encerramento ativo") }
        let note = receipt.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty { parts.append(note) }
        return parts.joined(separator: ", ")
    }

    static func spokenControlError(_ message: String) -> String {
        "erro de controle, \(message)"
    }

    private static func spokenAction(_ action: AtlasAutonomosRunAction) -> String {
        switch action {
        case .pause: return "pausar"
        case .resume: return "retomar"
        case .kill: return "encerrar"
        case .clearKill: return "limpar encerramento"
        }
    }
}
