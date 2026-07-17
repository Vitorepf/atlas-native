import SwiftUI
import AtlasCore

// Arena failed spoken — peel de AtlasArenaView+A11yScreen.

extension AtlasArenaView {
    func spokenArenaFailedLabel() -> String {
        if model.isDomainUnavailable, model.composite == nil {
            return domainUnavailableSpoken
        }
        return "Arena, falha ao carregar medição"
    }
}
