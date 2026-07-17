import SwiftUI
import AtlasCore

// Radar shell busy spoken — peel de AtlasCodeRadarView+A11yShell.

extension AtlasCodeRadarView {
    func radarShellBusyParts() -> [String]? {
        switch model.phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        default:
            return nil
        }
    }
}
