import SwiftUI
import AtlasCore

// Circle badge — peel de RootChrome+CircleButton.

extension CircleButton {
    @ViewBuilder
    var badgeOverlay: some View {
        if badge {
            Circle()
                .fill(AtlasCodePalette.alert)
                .frame(width: 9, height: 9)
                .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 1.5))
                .offset(x: 1, y: -1)
                .accessibilityHidden(true)
        }
    }
}
