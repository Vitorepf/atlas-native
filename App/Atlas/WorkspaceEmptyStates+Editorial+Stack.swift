import SwiftUI
import AtlasCore

// Editorial empty stack — peel de WorkspaceEmptyStates+Editorial+Glyph.
// Glyph → WorkspaceEmptyStates+Editorial+Stack+Glyph.swift
// CopyStack → WorkspaceEmptyStates+Editorial+Stack+CopyStack.swift

extension AtlasEditorialGlyphEmpty {
    var editorialStack: some View {
        VStack(spacing: 14) {
            editorialGlyph
            editorialCopyStack
        }
    }
}
