import SwiftUI
import AtlasCore

// CircleButton — peel de RootChrome+Controls.
// Badge → RootChrome+CircleButtonBadge.swift
// Label → RootChrome+CircleButton+Label.swift

struct CircleButton: View {
    let icon: String
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            circleButtonLabel
        }
        .accessibilityAddTraits(.isButton)
    }
}
