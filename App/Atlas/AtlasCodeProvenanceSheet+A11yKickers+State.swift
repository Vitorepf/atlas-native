import Foundation
import AtlasCore

// Provenance state kicker — peel de AtlasCodeProvenanceSheet+A11yKickers.

extension AtlasCodeProvenanceSheet {
    func spokenStateKicker() -> String {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .violating: return "fora da \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        case .history: return "história"
        }
    }
}
