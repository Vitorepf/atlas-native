import Foundation
import AtlasCore

/// Spoken labels do thumb de anexo — peel de DraftThumb (CICLO C).
/// Tamanho só quando bytes publicados; tipo imagem/arquivo honesto.

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
        "remover anexo \(draft.fileName)"
    }

    static let removeHint = "remove este anexo antes do envio"
    static let failedHint = "toque para ver o erro completo no aviso"

    static func spokenFailedValue(_ message: String) -> String {
        message.isEmpty ? "erro no envio" : message
    }
}
