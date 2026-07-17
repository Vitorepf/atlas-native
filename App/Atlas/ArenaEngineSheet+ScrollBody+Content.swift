import SwiftUI
import AtlasCore

// Scroll content — peel de ArenaEngineSheet+ScrollBody.
// Scroll → ArenaEngineSheet+ScrollBody+Content+Scroll.swift
// Inner → ArenaEngineSheet+ScrollBody+Content+Inner.swift

extension ArenaEngineSheet {
    var engineScrollContent: some View {
        engineScrollView
    }
}
