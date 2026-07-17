import SwiftUI
import AtlasCore

// Search miss empty — peel de SearchView+List.

struct SearchMissEmpty: View {
    let query: String
    let loadedThreadCount: Int

    private var headline: String {
        loadedThreadCount >= 100
            ? "“Nada com ‘\(query)’ nas 100 conversas mais recentes.”"
            : "“Nada com ‘\(query)’.”"
    }

    var body: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            accessibilityIdentifier: A11yID.searchEmpty
        )
    }
}
