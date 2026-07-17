import SwiftUI
import AtlasCore

// Law citation chrome — peel de AtlasCodeProvenanceSections.
// Body → AtlasCodeProvenanceSections+LawBody.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var lawCitationChrome: some View {
        if state == .violating, let ruleId, spokenLawCitation() != nil {
            lawCitationBody(ruleId: ruleId)
        }
    }
}
