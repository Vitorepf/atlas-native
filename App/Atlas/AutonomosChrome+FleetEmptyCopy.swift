import SwiftUI
import AtlasCore

/// Copy da frota vazia — peel de AutonomosChrome+Empty.

extension AutonomosFleetEmptyState {
    var copy: String {
        switch kind {
        case .noAgents:
            return "Nenhum agente publicado neste recorte — o servidor ainda não registrou a frota."
        case .noHistory:
            return "Histórico vazio — nenhum evento de governança registrado ainda."
        }
    }
}
