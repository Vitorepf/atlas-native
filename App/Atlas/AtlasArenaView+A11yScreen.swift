import SwiftUI
import AtlasCore

// Screen spoken — peel de AtlasArenaView+A11y.

extension AtlasArenaView {
    func spokenArenaScreenLabel() -> String {
        switch model.phase {
        case .idle, .loading:
            return "Arena, carregando índice medido"
        case .failed:
            if model.isDomainUnavailable, model.composite == nil {
                return domainUnavailableSpoken
            }
            return "Arena, falha ao carregar medição"
        case .loaded:
            return headerSpokenLabel
        }
    }
}
