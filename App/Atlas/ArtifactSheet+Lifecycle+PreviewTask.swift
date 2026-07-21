import SwiftUI
import AtlasCore

// Preview load task — peel de ArtifactSheet+Lifecycle.

extension ArtifactSheet {
    func artifactSheetPreviewTask(for item: AtlasTraceArtifacts.Item?) async {
        guard mountComplete, let item else { return }
        await load(item)
    }
}
