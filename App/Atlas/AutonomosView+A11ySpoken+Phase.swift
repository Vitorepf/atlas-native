import SwiftUI
import AtlasCore

// Autonomos phase spoken — peel de AutonomosView+A11ySpoken.

extension AutonomosView {
    func spokenScreenPhaseLabel() -> String {
        switch model.phase {
        case .idle, .loading:
            return "Autônomos, consultando a frota"
        case .failed:
            return "Autônomos, falha ao consultar a frota"
        case .loaded:
            if isHeaderHealthy {
                return "Autônomos, frota quieta"
            }
            return "Autônomos, frota carregada"
        }
    }
}
