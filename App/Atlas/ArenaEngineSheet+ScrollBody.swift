import SwiftUI
import AtlasCore

// Engine sheet scroll body — peel de ArenaEngineSheet.
// Content → ArenaEngineSheet+ScrollBody+Content.swift

extension ArenaEngineSheet {
    var engineScrollBody: some View {
        engineScrollNavChrome(engineScrollContent)
    }
}
