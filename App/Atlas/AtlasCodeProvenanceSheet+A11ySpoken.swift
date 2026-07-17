import Foundation
import AtlasCore

// Sheet spoken — peel de AtlasCodeProvenanceSheet+A11y.
// Kickers → AtlasCodeProvenanceSheet+A11yKickers.swift
// Phase → AtlasCodeProvenanceSheet+A11ySpoken+Phase.swift

extension AtlasCodeProvenanceSheet {
    var provenanceSheetSpokenLabel: String {
        var parts = ["proveniência do commit", spokenHeaderTitle(), spokenStateKicker()]
        parts.append(contentsOf: provenanceSheetPhaseParts())
        return parts.joined(separator: ", ")
    }
}
