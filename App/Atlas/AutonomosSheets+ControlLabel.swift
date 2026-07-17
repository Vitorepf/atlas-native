import SwiftUI
import AtlasCore

// Control sheet label — peel de AutonomosSheets+Control.

extension AutonomosControlSheet {
    var label: String {
        switch action {
        case .pause: return "Pausar"
        case .resume: return "Retomar"
        case .kill: return "Encerrar"
        case .clearKill: return "Liberar encerramento"
        }
    }
}
