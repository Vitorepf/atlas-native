import SwiftUI
import AtlasCore

// Loading/failed Why — peel de AtlasCodeWhySheet+Content.
// Loading → AtlasCodeWhySheet+LoadingState.swift
// Failed → AtlasCodeWhySheet+FailedState.swift

extension AtlasCodeWhySheet {
    @ViewBuilder
    var whyLoadingOrFailed: some View {
        switch model.phase {
        case .idle, .loading:
            whyLoading
        case .failed:
            whyFailed
        default:
            EmptyView()
        }
    }
}
