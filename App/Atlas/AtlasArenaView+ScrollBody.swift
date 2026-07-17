import SwiftUI
import AtlasCore

// Arena scroll body — peel de AtlasArenaView.
// Stack → AtlasArenaView+ScrollBody+Stack.swift
// Animation → AtlasArenaView+ScrollBody+Animation.swift

extension AtlasArenaView {
    var arenaScrollBody: some View {
        ScrollView {
            arenaScrollAnimated(arenaScrollStack)
        }
        .scrollIndicators(.hidden)
    }
}
