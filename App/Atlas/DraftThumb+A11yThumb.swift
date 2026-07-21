import AtlasCore
import Foundation

// Cycle 039 fuse → DraftThumb+A11yThumb.swift

extension DraftThumbA11y {
    static func spokenThumbSizeParts(_ draft: LocalDraft) -> [String] {
        guard draft.bytes > 0 else { return [] }
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        return ["\(mb) megabytes"]
    }
}

extension DraftThumbA11y {
    static func spokenThumbReadyParts(_ draft: LocalDraft) -> [String]? {
        switch draft.state {
        case .pronto: return ["pronto para enviar"]
        case .subindo: return ["enviando"]
        default: return nil
        }
    }
}

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

extension DraftThumbA11y {
    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        parts.append(contentsOf: spokenThumbSizeParts(draft))
        parts.append(contentsOf: spokenThumbStateParts(draft))
        return parts.joined(separator: ", ")
    }
}
