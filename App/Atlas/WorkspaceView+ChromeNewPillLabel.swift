import SwiftUI
import AtlasCore

// New pill label — peel de WorkspaceView+ChromeNewPill.

extension WorkspaceView {
    var newPillLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                .accessibilityHidden(true)
            Text("Escreva ao Atlas").font(.system(.callout)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Image(systemName: "mic.fill").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}
