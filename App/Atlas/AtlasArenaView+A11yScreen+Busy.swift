import SwiftUI
import AtlasCore

// Arena busy spoken — peel de AtlasArenaView+A11yScreen.

extension AtlasArenaView {
    func spokenArenaBusyLabel() -> String? {
        switch model.phase {
        case .idle, .loading:
            return "Arena, carregando índice medido"
        case .failed:
            return spokenArenaFailedLabel()
        default:
            return nil
        }
    }
}
