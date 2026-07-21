import SwiftUI
import AtlasCore

// New pill label — peel de WorkspaceView+ChromeNewPill.

extension WorkspaceView {
    // Mesma pílula agêntica da home: ✦ ouro + vidro (padrão §6). Sem mic —
    // voz está fora EM DEFINITIVO (canon §6).
    var newPillLabel: some View {
        HStack(spacing: 10) {
            Text("✦").font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
            Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .atlasGlassCapsule()
    }
}
