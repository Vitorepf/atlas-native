import SwiftUI
import AtlasCore

// Loaded header — peel de ArtifactSheet+ContentLoaded.

extension ArtifactSheet {
    var loadedArtifactsHeader: some View {
        Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
            .font(AtlasFont.mono(10)).tracking(1.0)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 14)
    }
}
