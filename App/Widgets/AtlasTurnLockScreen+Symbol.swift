import SwiftUI
import ActivityKit
import AtlasCore

/// Lock symbol — peel de AtlasTurnLockScreen+State.
/// Terminal → AtlasTurnLockScreen+Symbol+Terminal.swift

extension AtlasTurnAttributes.ContentState {
    var atlasSymbol: String {
        if let terminal = atlasSymbolTerminal { return terminal }
        if phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard") {
            return "⚠"
        }
        if paused == true { return "‖" }
        return "✦"
    }
}
