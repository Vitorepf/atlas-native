import Foundation
import AtlasCore

// Start-run receipt spoken — peel de AutonomosLoadedSection+A11y.

extension AutonomosLoadedSectionA11y {
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
}
