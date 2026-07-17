import SwiftUI
import AtlasCore

/// Artefatos — peel de ExecutionProof+Expanded+Blocks.

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onOpenArtifacts(traceId)
            } label: {
                HStack(spacing: 6) {
                    Text("⎘")
                        .font(AtlasFont.mono(12))
                        .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                        .frame(width: 15)
                        .accessibilityHidden(true)
                    Text("ARTEFATOS (\(artifactItems.count))")
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
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel("artefatos desta execução, \(artifactItems.count)")
            .accessibilityHint("abre a lista de artefatos deste trace")
        }
    }
}
