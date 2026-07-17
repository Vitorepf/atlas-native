import SwiftUI
import AtlasCore

// Artifacts button label — peel de ExecutionProof+Expanded+Artifacts.

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            Text("⎘")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            Text("ARTEFATOS (\(count))")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }
}
