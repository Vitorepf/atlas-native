import SwiftUI
import AtlasCore

// Preview loaded — peel de ArtifactSheet+PreviewStates.

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneLoaded: some View {
        if case .loaded(let item, let content) = preview {
            ArtifactPreviewContent(item: item, content: content)
        }
    }
}
