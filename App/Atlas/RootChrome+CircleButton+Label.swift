import SwiftUI
import AtlasCore

// Circle button label — peel de RootChrome+CircleButton.

extension CircleButton {
    var circleButtonLabel: some View {
        Image(systemName: icon)
            .atlasSans(17, .medium).foregroundStyle(AtlasTheme.textPrimary)
            .frame(width: 44, height: 44).background(Circle().fill(AtlasTheme.surface))
            .overlay(alignment: .topTrailing) {
                badgeOverlay
            }
    }
}
