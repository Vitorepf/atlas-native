import AtlasCore
import SwiftUI

// Content switch — peel de AtlasCodeRadarView.
// Branches → AtlasCodeRadarView+ContentBranches.swift
// Loading → AtlasCodeRadarView+Content+Loading.swift
// Busy → AtlasCodeRadarView+Content+Busy.swift

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContent: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            radarContentBusy
        case .loaded:
            radarLoadedOrEmpty
        }
    }
}
