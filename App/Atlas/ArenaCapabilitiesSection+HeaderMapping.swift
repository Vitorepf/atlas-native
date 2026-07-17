import SwiftUI
import AtlasCore

// Mapping version trailing — peel de ArenaCapabilitiesSection+Header.

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMapping(_ capabilities: AtlasArenaCapabilities) -> some View {
        if let mapping = capabilities.mappingVersion.nonEmpty {
            Text(mapping)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}
