import SwiftUI
import AtlasCore

// Healthy state labels — peel de Provenance StateLabel.

extension AtlasCodeProvenanceSheet {
    var stateLabelHealthy: String? {
        switch state {
        case .onMain: return "NA MAIN"
        case .healed: return "CURADO"
        default: return nil
        }
    }
}
