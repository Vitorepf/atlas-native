import SwiftUI
import AtlasCore

// LiveNow chrome — peel de LiveNowSection.

extension LiveNowSection {
    var liveNowChrome: some View {
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            header
            liveNowRows
        }
        .padding(14)
        .atlasCard()
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 18)
        .accessibilityIdentifier(A11yID.liveNowSection)
        .accessibilityLabel(Self.spokenSectionLabel(
            isHub: isHub, count: sessions.count, remoteCount: remoteCount
        ))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }
}
