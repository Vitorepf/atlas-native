import Foundation
import AtlasCore

// Thumb spoken — peel de DraftThumb+A11y.
// Size → DraftThumb+A11yThumb+Size.swift
// State → DraftThumb+A11yThumb+State.swift

extension DraftThumbA11y {
    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        parts.append(contentsOf: spokenThumbSizeParts(draft))
        parts.append(contentsOf: spokenThumbStateParts(draft))
        return parts.joined(separator: ", ")
    }
}
