import SwiftUI
import AtlasCore

// Glyph empty wiring — peel de WorkspaceEmptyStates+Editorial.

extension WorkspaceEditorialEmpty {
    var editorialGlyph: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel
        )
    }
}
