import SwiftUI
import ActivityKit
import AtlasCore

/// Fail/finished lock symbols — peel de AtlasTurnLockScreen+Symbol.

extension AtlasTurnAttributes.ContentState {
    var atlasSymbolTerminal: String? {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return "✕" }
        if finished { return "✓" }
        return nil
    }
}
