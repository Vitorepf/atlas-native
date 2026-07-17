import SwiftUI
import UIKit
import AtlasCore

// Linha da lista de artefatos — peel de ArtifactSheet+List.
// Label → ArtifactSheet+ListRowLabel.swift

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRow(index: Int, item: AtlasTraceArtifacts.Item) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selectedID = item.id
        } label: {
            artifactListRowLabel(item: item)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.artifactsItem(index))
        .accessibilityLabel("\(item.name), \(ArtifactViewer.byteLabel(item.byteSize)), \(ArtifactViewer.kindLabel(item.kind))")
        .accessibilityAddTraits(item.id == selected?.id ? .isSelected : [])
        .accessibilityHint(item.id == selected?.id ? "selecionado no preview" : "abre o preview deste artefato")
    }
}
