import SwiftUI
import AtlasCore

// Title column — peel de ArenaCapabilitiesSection+Header.

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesTitleColumn(_ capabilities: AtlasArenaCapabilities) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("CAPACIDADES")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            if let engine = capabilities.engine?.nonEmpty {
                Text(ArenaDisplay.engine(engine))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
