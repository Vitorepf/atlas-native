import SwiftUI
import AtlasCore

// Editorial glyph — peel de WorkspaceEmptyStates+Editorial+Stack.
// CopyStack → WorkspaceEmptyStates+Editorial+Stack+CopyStack.swift

extension AtlasEditorialGlyphEmpty {
    var editorialGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
    }
}
