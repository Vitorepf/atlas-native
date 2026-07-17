import SwiftUI
import UIKit
import AtlasCore

// Linha da lista de artefatos — peel de ArtifactSheet+List.

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRow(index: Int, item: AtlasTraceArtifacts.Item) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selectedID = item.id
        } label: {
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
                Text("\(ArtifactViewer.byteLabel(item.byteSize))  \(ArtifactViewer.kindLabel(item.kind))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.artifactsItem(index))
        .accessibilityLabel("\(item.name), \(ArtifactViewer.byteLabel(item.byteSize)), \(ArtifactViewer.kindLabel(item.kind))")
        .accessibilityAddTraits(item.id == selected?.id ? .isSelected : [])
        .accessibilityHint(item.id == selected?.id ? "selecionado no preview" : "abre o preview deste artefato")
    }
}
