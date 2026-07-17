import SwiftUI
import AtlasCore

// Conteúdo carregado da Arena — peel de AtlasArenaView (régua ≤110).
// Run → AtlasArenaView+RunButton.swift
// Loaded → AtlasArenaView+Loaded.swift

extension AtlasArenaView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle where model.composite == nil,
             .loading where model.composite == nil:
            loadingCard
        case .failed where model.composite == nil:
            if model.isDomainUnavailable {
                domainUnavailableCard
            } else {
                networkFailureCard
            }
        default:
            if let composite = model.composite {
                loadedArenaContent(composite)
            } else {
                domainUnavailableCard
            }
        }
    }
}
