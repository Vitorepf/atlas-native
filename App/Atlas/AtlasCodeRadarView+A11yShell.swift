import SwiftUI
import AtlasCore

// Radar shell spoken — peel de AtlasCodeRadarView+A11y.
// Loaded → AtlasCodeRadarView+A11yShell+Loaded.swift
// Busy → AtlasCodeRadarView+A11yShell+Busy.swift

extension AtlasCodeRadarView {
    var radarShellSpokenLabel: String {
        var parts = ["Código, workspace do operador"]
        if let busy = radarShellBusyParts() {
            parts.append(contentsOf: busy)
        } else {
            parts.append(contentsOf: radarShellLoadedParts())
        }
        return parts.joined(separator: ", ")
    }
}
