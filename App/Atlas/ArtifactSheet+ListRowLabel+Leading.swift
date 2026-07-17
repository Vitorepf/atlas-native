import SwiftUI
import AtlasCore

// Chevron + title — peel de ArtifactSheet+ListRowLabel.

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRowLeading(item: AtlasTraceArtifacts.Item) -> some View {
        Text("▸")
            .font(AtlasFont.mono(11))
            .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        Text(item.name)
            .font(AtlasFont.serif(15, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}
