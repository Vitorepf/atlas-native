import SwiftUI
import AtlasCore

// Estados editoriais — peel de WorkspaceEmptyStates.
// Copy → WorkspaceEmptyStates+Editorial+Copy.swift
// Glyph → WorkspaceEmptyStates+Editorial+Glyph.swift

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    var body: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel
        )
    }
}
