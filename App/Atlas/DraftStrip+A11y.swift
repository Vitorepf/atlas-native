import Foundation

// Cycle 041 fuse → DraftStrip+A11y.swift

enum DraftStripA11y {
    static func spokenStrip(draftCount: Int) -> String {
        let noun = draftCount == 1 ? "anexo" : "anexos"
        return "\(draftCount) \(noun) no composer"
    }
}
