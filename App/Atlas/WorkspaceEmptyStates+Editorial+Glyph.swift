import SwiftUI
import AtlasCore

// Glyph + headline editorial — peel de WorkspaceEmptyStates+Editorial.
// Stack → WorkspaceEmptyStates+Editorial+Stack.swift

/// ✦ + headline editorial compartilhado — workspace vazio e search miss.
struct AtlasEditorialGlyphEmpty: View {
    let headline: String
    var footnote: String? = nil
    let accessibilityIdentifier: String
    var spokenLabel: String? = nil

    var body: some View {
        editorialStack
            .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel ?? headline)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}
