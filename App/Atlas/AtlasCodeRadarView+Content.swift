import AtlasCore
import SwiftUI

// Content switch — peel de AtlasCodeRadarView.
// Branches → AtlasCodeRadarView+ContentBranches.swift

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContent: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(A11yID.radarLoading)
        case .failed(let message):
            radarFailed(message)
        case .loaded:
            radarLoadedOrEmpty
        }
    }
}
