import AtlasCore
import SwiftUI

// Content switch — peel de AtlasCodeRadarView.
// Branches → AtlasCodeRadarView+ContentBranches.swift
// Loading → AtlasCodeRadarView+Content+Loading.swift

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContent: some View {
        switch model.phase {
        case .idle, .loading:
            radarLoadingContent
        case .failed(let message):
            radarFailed(message)
        case .loaded:
            radarLoadedOrEmpty
        }
    }
}
