import SwiftUI
import ActivityKit
import AtlasCore

/// Lock symbol — peel de AtlasTurnLockScreen+State.

extension AtlasTurnAttributes.ContentState {
    var atlasSymbol: String {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return "✕" }
        if finished { return "✓" }
        if phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard") {
            return "⚠"
        }
        if paused == true { return "‖" }
        return "✦"
    }
}
