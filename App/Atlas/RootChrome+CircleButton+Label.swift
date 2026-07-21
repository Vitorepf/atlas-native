import SwiftUI
import AtlasCore

// Circle button label — peel de RootChrome+CircleButton.

extension CircleButton {
    var circleButtonLabel: some View {
        Image(systemName: icon)
            .atlasSans(15, .medium).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 44, height: 44).atlasGlassCircle()
            .overlay(alignment: .topTrailing) {
                badgeOverlay
            }
    }
}
