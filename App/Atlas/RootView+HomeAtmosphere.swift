import SwiftUI

// Atmosfera da home — peel de RootView+HomeStack.
// Véu editorial (teal + gold) sob a lista; silêncio, não dashboard.

extension RootView {
    var homeAtmosphere: some View {
        ZStack {
            AtlasTheme.bg
            RadialGradient(
                colors: [AtlasTheme.accent.opacity(0.045), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 320
            )
            RadialGradient(
                colors: [AtlasTheme.prussian.opacity(0.055), .clear],
                center: UnitPoint(x: 1.05, y: 0.82),
                startRadius: 10,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
