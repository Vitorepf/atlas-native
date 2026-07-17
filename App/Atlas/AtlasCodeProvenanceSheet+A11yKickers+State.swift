import Foundation
import AtlasCore

// Provenance state kicker — peel de AtlasCodeProvenanceSheet+A11yKickers.
// Healthy → AtlasCodeProvenanceSheet+A11yKickers+State+Healthy.swift

extension AtlasCodeProvenanceSheet {
    func spokenStateKicker() -> String {
        if let healthy = spokenStateKickerHealthy() { return healthy }
        switch state {
        case .violating: return "fora da \(trunk?.nonEmpty ?? "main")"
        case .history: return "história"
        default: return "história"
        }
    }
}
