import SwiftUI
import AtlasCore

// Provenance state kicker — peel de AtlasCodeProvenanceHeader.
// Glyph → AtlasCodeProvenanceHeader+StateKicker+Glyph.swift

extension AtlasCodeProvenanceSheet {
    var headerStateKicker: some View {
        headerStateKickerGlyph
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenStateKicker())
            .accessibilityIdentifier(A11yID.codeProvenanceState)
    }
}
