import SwiftUI
import ActivityKit
import AtlasCore

/// Terminal lock colors — peel de AtlasTurnLockScreen+State.

extension AtlasTurnAttributes.ContentState {
    var atlasColorTerminal: Color? {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return Ink.alert }
        if finished { return Ink.healed }
        return nil
    }
}
