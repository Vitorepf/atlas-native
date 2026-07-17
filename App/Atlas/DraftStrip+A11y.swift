import Foundation
import AtlasCore

/// Spoken labels da strip de anexos — peel de DraftStrip (CICLO C residual honesty).

enum DraftStripA11y {
    static func spokenStrip(draftCount: Int) -> String {
        let noun = draftCount == 1 ? "anexo" : "anexos"
        return "\(draftCount) \(noun) no composer"
    }

    static func spokenThumb(_ draft: LocalDraft) -> String {
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        var parts = ["anexo \(draft.fileName)", "\(mb) megabytes"]
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
