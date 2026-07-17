import Foundation
import AtlasCore

// Thumb spoken — peel de DraftThumb+A11y.

extension DraftThumbA11y {
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
}
