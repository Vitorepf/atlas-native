import SwiftUI
import AtlasCore

// Campo de busca — peel de SearchViewHeader.
// Clear → SearchView+HeaderClear.swift
// Leading → SearchView+HeaderFieldLeading.swift

extension SearchViewHeader {
    var searchFieldCapsule: some View {
        searchFieldLeading
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: focused)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: query.isEmpty)
    }
}
