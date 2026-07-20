import SwiftUI
import AtlasCore

// Autonomos phase spoken — peel de AutonomosView+A11ySpoken.
// Busy → AutonomosView+A11ySpoken+Phase+Busy.swift

extension AutonomosView {
    func spokenScreenPhaseLabel() -> String {
        if let busy = spokenScreenBusyLabel() { return busy }
        if isHeaderHealthy {
            return "Autônomos, catálogo quieto"
        }
        return "Autônomos, catálogo carregado"
    }
}
