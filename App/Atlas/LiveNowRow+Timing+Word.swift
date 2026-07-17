import SwiftUI
import AtlasCore

// Timing word — peel de LiveNowRow+Timing.

extension LiveNowRow {
    var timingWord: String {
        switch session.timing {
        case .running: return "em execução"
        case .paused: return "pausado"
        case .finished: return "concluído"
        }
    }
}
