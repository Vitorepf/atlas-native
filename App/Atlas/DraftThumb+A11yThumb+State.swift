import Foundation
import AtlasCore

// Thumb state spoken — peel de DraftThumb+A11yThumb.

extension DraftThumbA11y {
    static func spokenThumbStateParts(_ draft: LocalDraft) -> [String] {
        switch draft.state {
        case .pronto: return ["pronto para enviar"]
        case .subindo: return ["enviando"]
        case .falhou(let message):
            var parts = ["falhou"]
            if !message.isEmpty { parts.append(message) }
            return parts
        }
    }
}
