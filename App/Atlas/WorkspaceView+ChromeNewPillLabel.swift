import SwiftUI
import AtlasCore

// New pill label — peel de WorkspaceView+ChromeNewPill.

extension WorkspaceView {
    var newPillLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus").atlasSans(17, .medium)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                .accessibilityHidden(true)
            Text("Escreva ao Atlas").font(.system(.callout)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            // Sem mic: voz está fora EM DEFINITIVO (canon §6) e a pílula abre
            // composer de texto — o ícone prometia o que não existe.
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}
