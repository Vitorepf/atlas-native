import Foundation
import AtlasCore

// Thumb size spoken — peel de DraftThumb+A11yThumb.

extension DraftThumbA11y {
    static func spokenThumbSizeParts(_ draft: LocalDraft) -> [String] {
        guard draft.bytes > 0 else { return [] }
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        return ["\(mb) megabytes"]
    }
}
