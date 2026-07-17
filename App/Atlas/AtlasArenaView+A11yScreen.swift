import SwiftUI
import AtlasCore

// Screen spoken — peel de AtlasArenaView+A11y.
// Failed → AtlasArenaView+A11yScreen+Failed.swift

extension AtlasArenaView {
    func spokenArenaScreenLabel() -> String {
        switch model.phase {
        case .idle, .loading:
            return "Arena, carregando índice medido"
        case .failed:
            return spokenArenaFailedLabel()
        case .loaded:
            return headerSpokenLabel
        }
    }
}
