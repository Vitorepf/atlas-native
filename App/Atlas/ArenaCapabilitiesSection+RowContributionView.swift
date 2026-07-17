import SwiftUI
import Charts
import AtlasCore

// Contribution line view — peel de ArenaCapabilitiesSection+Rows.

extension ArenaCapabilityRow {
    @ViewBuilder
    var contributionLineView: some View {
        if !contributionLine.isEmpty {
            Text(contributionLine)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
