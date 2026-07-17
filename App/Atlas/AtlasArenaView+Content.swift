import SwiftUI
import AtlasCore

// Conteúdo carregado da Arena — peel de AtlasArenaView (régua ≤110).
// Run → AtlasArenaView+RunButton.swift
// Loaded → AtlasArenaView+Loaded.swift
// Failed → AtlasArenaView+ContentFailed.swift

extension AtlasArenaView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle where model.composite == nil,
             .loading where model.composite == nil:
            loadingCard
        case .failed where model.composite == nil:
            failedOrUnavailableCard
        default:
            if let composite = model.composite {
                loadedArenaContent(composite)
            } else {
                domainUnavailableCard
            }
        }
    }
}
