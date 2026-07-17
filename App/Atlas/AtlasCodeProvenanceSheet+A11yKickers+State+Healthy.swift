import Foundation
import AtlasCore

// Healthy state kickers — peel de Provenance A11yKickers State.

extension AtlasCodeProvenanceSheet {
    func spokenStateKickerHealthy() -> String? {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        default: return nil
        }
    }
}
