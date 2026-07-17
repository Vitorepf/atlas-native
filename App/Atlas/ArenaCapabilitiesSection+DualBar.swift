import SwiftUI
import Charts
import AtlasCore

// DualBar — peel de ArenaCapabilitiesSection+Rows.
// Track → ArenaCapabilitiesSection+DualBarTrack.swift

struct DualBar: View {
    let score: Double?
    let withAtlas: Double?

    var body: some View {
        VStack(spacing: 4) {
            bar(score, color: AtlasTheme.textSecondary)
            bar(withAtlas, color: AtlasTheme.accent)
        }
        .accessibilityHidden(true)
    }
}
