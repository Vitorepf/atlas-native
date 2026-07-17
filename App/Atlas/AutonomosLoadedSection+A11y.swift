import Foundation
import AtlasCore

/// Spoken labels do corpo carregado — peel de AutonomosLoadedSection (CICLO C).
/// Recibos só com campos publicados; fila ≠ execução; erro = mensagem real do servidor.
/// Control → AutonomosLoadedSection+A11yControl.swift

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
        AutonomosLoadedSectionA11yControl.spokenControlReceipt(receipt)
    }

    static func spokenControlError(_ message: String) -> String {
        AutonomosLoadedSectionA11yControl.spokenControlError(message)
    }
}
