import SwiftUI
import ActivityKit
import AtlasCore

// Timer a11y — peel de AtlasTurnWidget+Timer.

extension AtlasTurnWidgetTimer {
    var timerA11y: String {
        if paused == true {
            return "tempo ativo congelado em \(pausedDisplay ?? "indisponível")"
        }
        return "tempo ativo"
    }
}
