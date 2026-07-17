import SwiftUI
import AtlasCore

// Preview loading/failed — peel de ArtifactSheet+PreviewStates.
// Loading → ArtifactSheet+PreviewStates+Busy+Loading.swift

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneBusyOrFailed: some View {
        switch preview {
        case .idle, .loading:
            previewPaneLoading
        case .tooLarge(let bytes):
            previewPaneFailure(bytes: bytes)
        case .failed(let message):
            previewPaneFailure(message: message)
        default:
            EmptyView()
        }
    }
}
