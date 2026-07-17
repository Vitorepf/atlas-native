import SwiftUI
import AtlasCore

// Preview loading/failed — peel de ArtifactSheet+PreviewStates.

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneBusyOrFailed: some View {
        switch preview {
        case .idle, .loading:
            TraceEvidenceLoading(text: "carregando preview…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, minHeight: 180)
        case .tooLarge(let bytes):
            previewPaneFailure(bytes: bytes)
        case .failed(let message):
            previewPaneFailure(message: message)
        default:
            EmptyView()
        }
    }
}
