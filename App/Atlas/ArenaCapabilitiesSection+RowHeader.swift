import SwiftUI
import AtlasCore

// Row header — peel de ArenaCapabilitiesSection+Rows.

extension ArenaCapabilityRow {
    var capabilityHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(capability.labelPt)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            Spacer()
            Text("\(ArenaFormat.score(capability.score)) · Atlas \(ArenaFormat.score(capability.withAtlas))")
                .font(AtlasFont.mono(11))
                .foregroundStyle(capability.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}
