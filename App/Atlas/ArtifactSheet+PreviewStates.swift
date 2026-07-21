import SwiftUI
import AtlasCore

// Preview loaded / failed branches — peel de ArtifactSheet+Preview.
// Failure → ArtifactSheet+PreviewFailure.swift
// Busy → ArtifactSheet+PreviewStates+Busy.swift
// Loaded → ArtifactSheet+PreviewStates+Loaded.swift

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneStates: some View {
        switch preview {
        case .idle, .loading, .tooLarge, .failed:
            previewPaneBusyOrFailed
        case .loaded:
            previewPaneLoaded
        }
    }
}
