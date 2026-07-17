import Foundation
import AtlasCore

// Thumb ready/upload spoken — peel de DraftThumb+A11yThumb+State.

extension DraftThumbA11y {
    static func spokenThumbReadyParts(_ draft: LocalDraft) -> [String]? {
        switch draft.state {
        case .pronto: return ["pronto para enviar"]
        case .subindo: return ["enviando"]
        default: return nil
        }
    }
}
