import SwiftUI
import AtlasCore

/// Estados loading/failed/loaded — peel de AtlasCodeWhySheet (régua ≤100).
/// Loading/failed → AtlasCodeWhySheet+Loading.swift

extension AtlasCodeWhySheet {
    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyLoadingOrFailed
        case .loaded:
            if let why = model.why {
                whyLoadedCommits(why)
            }
        }
    }
}
