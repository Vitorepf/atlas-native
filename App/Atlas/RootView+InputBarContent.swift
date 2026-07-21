import SwiftUI
import AtlasCore

// Conteúdo visual do input pill — peel de RootView+InputBar.

extension RootView {
    // A pílula agêntica: ✦ vivo + Liquid Glass + fio de ouro artesanal.
    var inputBarContent: some View {
        HStack(spacing: 12) {
            HomeComposerStar()
            Text("Escreva ao Atlas")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .atlasGlassCapsule()
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            AtlasTheme.accent.opacity(0.22),
                            AtlasTheme.accent.opacity(0.04),
                            AtlasTheme.accent.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        )
    }
}
