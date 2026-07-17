import SwiftUI
import AtlasCore

// Preview too large — peel de ArtifactSheet+PreviewFailure.

extension ArtifactSheet {
    @ViewBuilder
    func previewTooLarge(bytes: Int) -> some View {
        ArtifactFileFicha(
            name: selected?.name ?? "artefato",
            subtitle: "grande demais para visualizar aqui · \(ArtifactViewer.byteLabel(bytes))"
        )
        .accessibilityLabel(
            ArtifactViewerA11y.spokenTooLarge(
                name: selected?.name ?? "artefato",
                bytes: bytes
            )
        )
    }
}
