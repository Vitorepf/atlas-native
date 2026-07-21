import SwiftUI
import AtlasCore

// Autonomos busy spoken — peel de AutonomosView+A11ySpoken+Phase.

extension AutonomosView {
    func spokenScreenBusyLabel() -> String? {
        switch model.phase {
        case .idle, .loading:
            return "Autônomos, abrindo catálogo"
        case .failed:
            return "Autônomos, falha ao abrir catálogo"
        default:
            return nil
        }
    }
}
