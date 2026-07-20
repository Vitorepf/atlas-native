import SwiftUI

/// Destinos push Autônomos v9 — lista é a raiz (destination == nil).
enum AutonomosDestination: Hashable, Identifiable {
    case hub
    case evolution
    case decisions
    case decisionInbox(String)
    case decisionOrder(String)
    case moment(String)
    case incident

    var id: String {
        switch self {
        case .hub: "hub"
        case .evolution: "evolution"
        case .decisions: "decisions"
        case .decisionInbox(let h): "inbox-\(h)"
        case .decisionOrder(let id): "order-\(id)"
        case .moment(let id): "moment-\(id)"
        case .incident: "incident"
        }
    }

    var navTitle: String {
        switch self {
        case .hub: "Autônomo"
        case .evolution: "Evolução"
        case .decisions: "Decisões"
        case .decisionInbox, .decisionOrder: "Decisão"
        case .moment: "Momento"
        case .incident: "Precisa de você"
        }
    }

    /// Voltar hierárquico: profundidade → hub → lista.
    var backTarget: AutonomosDestination? {
        switch self {
        case .hub: nil
        default: .hub
        }
    }
}
