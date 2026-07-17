import SwiftUI
import AtlasCore

// Law citation body — peel de AtlasCodeProvenanceSections+LawChrome.
// Pad/chrome → AtlasCodeProvenanceSections+LawChromePad.swift
// Rule → AtlasCodeProvenanceSections+LawBody+Rule.swift
// Canon → AtlasCodeProvenanceSections+LawBody+Canon.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCitationBody(ruleId: String) -> some View {
        lawCitationChrome(
            VStack(alignment: .leading, spacing: 3) {
                lawRuleText(ruleId)
                if let ruleCanon = ruleCanon?.nonEmpty {
                    lawCanonText(ruleCanon)
                }
            }
        )
    }
}
