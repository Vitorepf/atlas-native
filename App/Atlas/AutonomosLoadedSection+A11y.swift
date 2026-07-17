import Foundation
import AtlasCore

/// Spoken labels do corpo carregado — peel de AutonomosLoadedSection (CICLO C).
/// Recibos só com campos publicados; fila ≠ execução; erro = mensagem real do servidor.

enum AutonomosLoadedSectionA11y {
    static func spokenStartRunEnqueued(_ receipt: AtlasAutonomosStartRunResponse) -> String {
        var parts = ["novo ciclo na fila, ainda não iniciado"]
        parts.append("modo \(receipt.mode.rawValue)")
        if receipt.execute { parts.append("execução real solicitada") }
        if receipt.requiresWorker { parts.append("aguarda worker") }
        let note = receipt.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty { parts.append(note) }
        parts.append("execução só é real quando o lease aparecer no vivo")
        return parts.joined(separator: ", ")
    }

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
