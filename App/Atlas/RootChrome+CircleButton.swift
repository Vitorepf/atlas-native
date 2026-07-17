import SwiftUI
import AtlasCore

// CircleButton — peel de RootChrome+Controls.

struct CircleButton: View {
    let icon: String
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44).background(Circle().fill(AtlasTheme.surface))
                .overlay(alignment: .topTrailing) {
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
        .accessibilityAddTraits(.isButton)
    }
}
