import SwiftUI
import AtlasCore

// Inner stack — peel de ArenaEngineSheet+ScrollBody+Content.

extension ArenaEngineSheet {
    var engineScrollInnerStack: some View {
        VStack(alignment: .leading, spacing: 16) {
            engineScrollTitle
            engineSummary
            ArenaCapabilitiesSection(capabilities: capabilities, reduceMotion: reduceMotion)
        }
    }
}
