import SwiftUI
import AtlasCore

// Engine sheet scroll body — peel de ArenaEngineSheet.
// Title → ArenaEngineSheet+ScrollBody+Title.swift
// NavChrome → ArenaEngineSheet+ScrollBody+NavChrome.swift

extension ArenaEngineSheet {
    var engineScrollBody: some View {
        engineScrollNavChrome(
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    engineScrollTitle
                    engineSummary
                    ArenaCapabilitiesSection(capabilities: capabilities, reduceMotion: reduceMotion)
                }
                .padding(AtlasTheme.Space.screen)
            }
        )
    }
}
