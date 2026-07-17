import SwiftUI
import AtlasCore

// Estados tooLarge/failed do preview — peel de ArtifactSheet+PreviewStates.

extension ArtifactSheet {
    @ViewBuilder
    func previewPaneFailure(bytes: Int? = nil, message: String? = nil) -> some View {
        if let bytes {
            previewTooLarge(bytes: bytes)
        } else if let message {
            previewMessageFailure(message)
        }
    }
}
