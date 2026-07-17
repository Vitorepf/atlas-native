import Foundation
import AtlasCore

// Provenance loaded phase spoken — peel de AtlasCodeProvenanceSheet+A11ySpoken+Phase.

extension AtlasCodeProvenanceSheet {
    func provenanceSheetLoadedParts(_ provenance: AtlasCodeProvenance) -> [String] {
        if let headline = provenance.diffHeadline { return [headline] }
        if !hasLoadedBody(provenance) { return ["ledger sem detalhe neste recorte"] }
        return []
    }
}
