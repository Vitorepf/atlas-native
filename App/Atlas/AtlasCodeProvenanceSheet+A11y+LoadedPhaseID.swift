import Foundation
import AtlasCore

/// Provenance loaded phase id — peel de AtlasCodeProvenanceSheet+A11y.

extension AtlasCodeProvenanceSheet {
    func provenanceLoadedPhaseID(_ provenance: AtlasCodeProvenance) -> String {
        hasLoadedBody(provenance) ? "loaded-\(provenance.files.count)" : "loaded-empty"
    }
}
