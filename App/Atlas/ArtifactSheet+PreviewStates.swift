import SwiftUI
import AtlasCore

// Preview loaded / failed branches — peel de ArtifactSheet+Preview.
// Failure → ArtifactSheet+PreviewFailure.swift

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneStates: some View {
        switch preview {
        case .idle, .loading:
            TraceEvidenceLoading(text: "carregando preview…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, minHeight: 180)
        case .tooLarge(let bytes):
            previewPaneFailure(bytes: bytes)
        case .failed(let message):
            previewPaneFailure(message: message)
        case .loaded(let item, let content):
            ArtifactPreviewContent(item: item, content: content)
        }
    }
}
