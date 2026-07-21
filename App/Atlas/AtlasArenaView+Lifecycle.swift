import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasArenaView+Lifecycle.swift

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
            // O título de navegação já anuncia a superfície. Label/ID no
            // container inteiro substituía o nome e o ID de cada tab e CTA.
    }
}

extension AtlasArenaView {
    func arenaLifecycleTasks<Content: View>(_ content: Content) -> some View {
        content
            .task {
                if case .idle = model.phase {
                    await model.load()
                }
            }
            .onAppear { model.setVisible(true) }
            .onDisappear { model.setVisible(false) }
            .refreshable { await model.load() }
    }
}

extension AtlasArenaView {
    func arenaLifecycleChrome<Content: View>(_ content: Content) -> some View {
        arenaLifecycleTasks(arenaLifecycleA11y(content))
    }
}
