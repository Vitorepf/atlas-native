import SwiftUI
import AtlasCore

// Pause/resume control labels — peel de AutonomosSheets+ControlLabel.

extension AutonomosControlSheet {
    var labelSoft: String? {
        switch action {
        case .pause: return "Pausar"
        case .resume: return "Retomar"
        default: return nil
        }
    }
}
