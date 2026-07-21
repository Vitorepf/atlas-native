import SwiftUI
import AtlasCore

// Loaded artifact list+preview — peel de ArtifactSheet+Content.
// Header → ArtifactSheet+ContentLoaded+Header.swift
// Scroll → ArtifactSheet+ContentLoaded+Scroll.swift

extension ArtifactSheet {
    var loadedArtifactsBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            loadedArtifactsHeader
            loadedArtifactsScroll
        }
    }
}
