import Foundation

/// Spoken labels da strip de anexos — peel de DraftStrip (CICLO C residual honesty).

enum DraftStripA11y {
    static func spokenStrip(draftCount: Int) -> String {
        let noun = draftCount == 1 ? "anexo" : "anexos"
        return "\(draftCount) \(noun) no composer"
    }
}
