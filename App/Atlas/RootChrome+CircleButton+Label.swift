import SwiftUI
import AtlasCore

// Circle button label — peel de RootChrome+CircleButton.

extension CircleButton {
    var circleButtonLabel: some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .medium)).foregroundStyle(AtlasTheme.textPrimary)
            .frame(width: 44, height: 44).background(Circle().fill(AtlasTheme.surface))
            .overlay(alignment: .topTrailing) {
                badgeOverlay
            }
    }
}
