import SwiftUI
import AtlasCore

// Preview pane — peel de ArtifactSheet+Content.
// Load/state → ArtifactSheet+PreviewLoad.swift
// States → ArtifactSheet+PreviewStates.swift

extension ArtifactSheet {
    @ViewBuilder
    var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            previewPaneStates
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
    }
}
