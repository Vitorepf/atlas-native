import Foundation
import AtlasCore

/// Spoken labels do thumb de anexo — peel de DraftThumb (CICLO C).
/// Tamanho só quando bytes publicados; tipo imagem/arquivo honesto.
/// Hints → DraftThumb+A11yHints.swift

enum DraftThumbA11y {
    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        if draft.bytes > 0 {
            let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
            parts.append("\(mb) megabytes")
        }
        switch draft.state {
        case .pronto: parts.append("pronto para enviar")
        case .subindo: parts.append("enviando")
        case .falhou(let message):
            parts.append("falhou")
            if !message.isEmpty { parts.append(message) }
        }
        return parts.joined(separator: ", ")
    }

    static func spokenRemove(_ draft: LocalDraft) -> String {
        DraftThumbA11yHints.spokenRemove(draft)
    }

    static let removeHint = DraftThumbA11yHints.removeHint
    static let failedHint = DraftThumbA11yHints.failedHint

    static func spokenFailedValue(_ message: String) -> String {
        DraftThumbA11yHints.spokenFailedValue(message)
    }
}
