import SwiftUI
import AtlasCore

// Root lifecycle tasks — peel de RootView.
// Threads → RootView+Lifecycle+Threads.swift
// CodeHub → RootView+Lifecycle+CodeHub.swift
// Arena → RootView+Lifecycle+Arena.swift
// DeepLink → RootView+Lifecycle+DeepLink.swift
// TintAppear → RootView+Lifecycle+TintAppear.swift

extension RootView {
    func rootLifecycleChrome<Content: View>(_ content: Content) -> some View {
        rootLifecycleDeepLink(
            rootLifecycleArena(
                rootLifecycleCodeHub(
                    rootLifecycleThreads(
                        rootLifecycleTintAppear(content)
                    )
                )
            )
        )
    }
}
