import Foundation
import AtlasCore

// hasLoadedBody — peel de AtlasCodeProvenanceSheet+A11y.

extension AtlasCodeProvenanceSheet {
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }
}
