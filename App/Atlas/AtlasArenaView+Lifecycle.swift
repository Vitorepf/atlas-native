import SwiftUI
import AtlasCore

// Arena lifecycle + a11y — peel de AtlasArenaView.
// A11y → AtlasArenaView+Lifecycle+A11y.swift
// Tasks → AtlasArenaView+Lifecycle+Tasks.swift

extension AtlasArenaView {
    func arenaLifecycleChrome<Content: View>(_ content: Content) -> some View {
        arenaLifecycleTasks(arenaLifecycleA11y(content))
    }
}
