import SwiftUI
import AtlasCore

// Conteúdo visual do input pill — peel de RootView+InputBar.

extension RootView {
    var inputBarContent: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                .accessibilityHidden(true)
            Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}
