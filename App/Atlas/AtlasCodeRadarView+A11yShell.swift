import SwiftUI
import AtlasCore

// Radar shell spoken — peel de AtlasCodeRadarView+A11y.
// Loaded → AtlasCodeRadarView+A11yShell+Loaded.swift

extension AtlasCodeRadarView {
    var radarShellSpokenLabel: String {
        var parts = ["Código, workspace do operador"]
        switch model.phase {
        case .idle, .loading:
            parts.append(spokenLoading())
        case .failed(let message):
            parts.append(spokenFailed(message))
        case .loaded:
            parts.append(contentsOf: radarShellLoadedParts())
        }
        return parts.joined(separator: ", ")
    }
}
