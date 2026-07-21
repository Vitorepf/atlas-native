import SwiftUI
import AtlasCore

// Loaded scroll — peel de ArtifactSheet+ContentLoaded.

extension ArtifactSheet {
    var loadedArtifactsScroll: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                artifactList
                previewPane
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}
