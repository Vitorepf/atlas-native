import Foundation
import AtlasCore

/// Vestimenta do hub de um Autônomo soberano (v9).
enum AutonomosHubVestment: Equatable {
    case awaiting(Int)
    case live
    case quiet

    static func resolve(
        backlog: AtlasAutonomosBacklogResponse?,
        live: AtlasAutonomosLiveResponse?,
        incidentPresent: Bool
    ) -> AutonomosHubVestment {
        let decisions: Int = {
            guard let backlog else { return 0 }
            return backlog.inboxItems.filter(\.decisionRequired).count
                + backlog.workOrders.filter(\.operatorDecisionRequired).count
        }()
        if decisions > 0 { return .awaiting(decisions) }
        if live?.isRunning == true { return .live }
        if incidentPresent { return .live }
        return .quiet
    }

    var kicker: String {
        switch self {
        case .awaiting: "Pede você"
        case .live: "Vivo"
        case .quiet: "Parado"
        }
    }

    var kickerLive: Bool {
        switch self {
        case .awaiting, .live: true
        case .quiet: false
        }
    }

    var heroTitle: String {
        switch self {
        case .awaiting(let n):
            return n == 1 ? "1 decisão" : "\(n) decisões"
        case .live:
            return "Evoluindo"
        case .quiet:
            return "Em pausa"
        }
    }

    var heroSub: String {
        switch self {
        case .awaiting:
            return "Só o julgamento desbloqueia."
        case .live:
            return "Nada pede você."
        case .quiet:
            return "Por você."
        }
    }

    var navSubtitle: String {
        switch self {
        case .awaiting: "Pede você"
        case .live: "Vivo"
        case .quiet: "Parado"
        }
    }
}
