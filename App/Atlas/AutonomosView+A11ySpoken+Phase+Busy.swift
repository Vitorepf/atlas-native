import SwiftUI
import AtlasCore

// Autonomos busy spoken — peel de AutonomosView+A11ySpoken+Phase.

extension AutonomosView {
    func spokenScreenBusyLabel() -> String? {
        switch model.phase {
        case .idle, .loading:
            return "Autônomos, consultando a frota"
        case .failed:
            return "Autônomos, falha ao consultar a frota"
        default:
            return nil
        }
    }
}
