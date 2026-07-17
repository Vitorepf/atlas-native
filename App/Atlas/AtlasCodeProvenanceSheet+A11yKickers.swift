import Foundation
import AtlasCore

// Header/state kickers — peel de AtlasCodeProvenanceSheet+A11ySpoken.

extension AtlasCodeProvenanceSheet {
    func spokenHeaderTitle() -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }

    func spokenStateKicker() -> String {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .violating: return "fora da \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        case .history: return "história"
        }
    }
}
