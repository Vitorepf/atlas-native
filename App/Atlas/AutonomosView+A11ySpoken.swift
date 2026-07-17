import SwiftUI
import AtlasCore

// Screen spoken — peel de AutonomosView+A11y.

extension AutonomosView {
    func spokenScreenLabel() -> String {
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

    static let screenHint = "frota, digest e áreas só com dados publicados pelo servidor"
}
