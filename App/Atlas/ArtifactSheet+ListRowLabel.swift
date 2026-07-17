import SwiftUI
import UIKit
import AtlasCore

// Artifact list row label — peel de ArtifactSheet+ListRow.
// Meta → ArtifactSheet+ListRowMeta.swift

extension ArtifactSheet {
    func artifactListRowLabel(item: AtlasTraceArtifacts.Item) -> some View {
        HStack(spacing: 10) {
            Text("▸")
                .font(AtlasFont.mono(11))
                .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(item.name)
                .font(AtlasFont.serif(15, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            Spacer()
            artifactListRowMeta(item: item)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
