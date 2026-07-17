import SwiftUI
import AtlasCore

// Artifacts button label — peel de ExecutionProof+Expanded+Artifacts.
// Chevron → ExecutionProof+Expanded+ArtifactsChevron.swift

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
            artifactsChevron
        }
        .contentShape(Rectangle())
    }
}
