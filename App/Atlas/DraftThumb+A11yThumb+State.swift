import Foundation
import AtlasCore

// Thumb state spoken — peel de DraftThumb+A11yThumb.
// Ready → DraftThumb+A11yThumb+State+Ready.swift

extension DraftThumbA11y {
    static func spokenThumbStateParts(_ draft: LocalDraft) -> [String] {
        if let ready = spokenThumbReadyParts(draft) { return ready }
        if case .falhou(let message) = draft.state {
            var parts = ["falhou"]
            if !message.isEmpty { parts.append(message) }
            return parts
        }
        return []
    }
}
