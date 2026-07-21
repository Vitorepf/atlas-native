import SwiftUI
import AtlasCore

/// Estados loading/failed/loaded — peel de AtlasCodeWhySheet (régua ≤100).
/// Loading/failed → AtlasCodeWhySheet+Loading.swift
/// Busy → AtlasCodeWhySheet+Content+Busy.swift

extension AtlasCodeWhySheet {
    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyBusyContent
        case .loaded:
            if let why = model.why {
                whyLoadedCommits(why)
            }
        }
    }
}
