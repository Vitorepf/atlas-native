import Foundation
import AtlasCore

// Header/state kickers — peel de AtlasCodeProvenanceSheet+A11ySpoken.
// State → AtlasCodeProvenanceSheet+A11yKickers+State.swift

extension AtlasCodeProvenanceSheet {
    func spokenHeaderTitle() -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }
}
