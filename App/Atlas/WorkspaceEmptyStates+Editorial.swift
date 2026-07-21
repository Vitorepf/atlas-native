import SwiftUI
import AtlasCore

// Estados editoriais — peel de WorkspaceEmptyStates.
// Copy → WorkspaceEmptyStates+Editorial+Copy.swift
// Glyph → WorkspaceEmptyStates+Editorial+Glyph.swift
// Body → WorkspaceEmptyStates+EditorialGlyph.swift

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    var body: some View {
        editorialGlyph
    }
}
