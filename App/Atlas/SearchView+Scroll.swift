import SwiftUI
import AtlasCore

/// Lista / loading / offline / miss — peel de SearchView (régua ≤100).
/// Query content → SearchView+ScrollQuery.swift
/// Shell → SearchView+ScrollShell.swift

extension SearchView {
    var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                listShellContent
            }
            .padding(.bottom, 40)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: trimmedQuery)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: session.threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await session.loadThreads() }
    }
}
