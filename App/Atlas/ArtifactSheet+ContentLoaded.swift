import SwiftUI
import AtlasCore

// Loaded artifact list+preview — peel de ArtifactSheet+Content.

extension ArtifactSheet {
    var loadedArtifactsBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
                .font(AtlasFont.mono(10)).tracking(1.0)
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
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
}
