import SwiftUI
import AtlasCore

// Shell de conteúdo — peel de ArtifactSheet.
// Empty → ArtifactSheet+Empty.swift
// Loaded → ArtifactSheet+ContentLoaded.swift

extension ArtifactSheet {
    @ViewBuilder
    var content: some View {
        if showsEmptyOrUnavailable {
            emptyOrUnavailable
        } else if hasDeliveryProof, !mountComplete {
            artifactMount
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
        } else {
            loadedArtifactsBody
        }
    }
}
