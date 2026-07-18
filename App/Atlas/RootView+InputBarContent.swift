import SwiftUI
import AtlasCore

// Conteúdo visual do input pill — peel de RootView+InputBar.

extension RootView {
    // A pílula agêntica: o ✦ da casa em ouro + vidro do sistema (padrão §6).
    var inputBarContent: some View {
        HStack(spacing: 10) {
            // Halo discreto: o ✦ respira como no site (goldVeil, nunca grito).
            Text("✦").font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 30, height: 30)
                .background(Circle().fill(AtlasTheme.goldVeil).blur(radius: 5))
                .accessibilityHidden(true)
            Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .atlasGlassCapsule()
    }
}
