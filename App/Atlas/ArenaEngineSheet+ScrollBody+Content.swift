import SwiftUI
import AtlasCore

// Scroll content — peel de ArenaEngineSheet+ScrollBody.

extension ArenaEngineSheet {
    var engineScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                engineScrollTitle
                engineSummary
                ArenaCapabilitiesSection(capabilities: capabilities, reduceMotion: reduceMotion)
            }
            .padding(AtlasTheme.Space.screen)
        }
    }
}
