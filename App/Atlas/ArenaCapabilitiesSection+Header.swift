import SwiftUI
import AtlasCore

// Header capacidades — peel de ArenaCapabilitiesSection.

extension ArenaCapabilitiesSection {
    func capabilitiesHeader(_ capabilities: AtlasArenaCapabilities) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("CAPACIDADES")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                if let engine = capabilities.engine?.nonEmpty {
                    Text(engine)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            Spacer()
            if let mapping = capabilities.mappingVersion.nonEmpty {
                Text(mapping)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
        }
    }
}
