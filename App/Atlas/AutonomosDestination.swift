import Foundation

/// Destinos vivos da face Autônomos v9: lista → hub → evolução.
/// Decisões/incidentes do motor ficam para §5 create — não há rota local mentindo superfície.
enum AutonomosDestination: Hashable, Identifiable {
    case hub
    case evolution

    var id: String {
        switch self {
        case .hub: "hub"
        case .evolution: "evolution"
        }
    }

    var navTitle: String {
        switch self {
        case .hub: "Autônomo"
        case .evolution: "Evolução"
        }
    }

    /// Voltar hierárquico: evolução → hub → lista.
    var backTarget: AutonomosDestination? {
        switch self {
        case .hub: nil
        case .evolution: .hub
        }
    }
}

/// Vestimenta do hub (v9) — quiet/live do catálogo local; sem contagem de backlog.
enum AutonomosHubVestment: Equatable {
    case live
    case quiet
}
