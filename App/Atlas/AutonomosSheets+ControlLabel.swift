import SwiftUI
import AtlasCore

// Control sheet label — peel de AutonomosSheets+Control.
// Soft → AutonomosSheets+ControlLabel+Soft.swift

extension AutonomosControlSheet {
    var label: String {
        if let soft = labelSoft { return soft }
        switch action {
        case .kill: return "Encerrar"
        case .clearKill: return "Liberar encerramento"
        default: return "Pausar"
        }
    }
}
