import SwiftUI
import AtlasCore

// Index stack — peel de ArenaIndexSection+Content.

extension ArenaIndexSection {
    var indexContentStack: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            engineRows
            indexContentChart
        }
    }
}
