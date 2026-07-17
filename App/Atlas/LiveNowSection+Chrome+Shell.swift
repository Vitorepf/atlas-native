import SwiftUI
import AtlasCore

// Section shell — peel de LiveNowSection+Chrome.

extension LiveNowSection {
    var liveNowSectionShell: some View {
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            header
            liveNowRows
        }
        .padding(14)
        .atlasCard()
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 18)
    }
}
