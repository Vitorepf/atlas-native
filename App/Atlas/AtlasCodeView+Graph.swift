import SwiftUI
import AtlasCore

// Graph content — Loading → AtlasCodeView+Graph+Loading.swift
// Loaded → AtlasCodeView+Graph+Loaded.swift

extension AtlasCodeView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            graphLoadingContent
        case .failed(let message):
            graphFailure(message)
        case .loaded:
            graphLoadedContent
        }
    }
}
