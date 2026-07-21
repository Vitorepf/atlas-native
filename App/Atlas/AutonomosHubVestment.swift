import Foundation
import AtlasCore

/// Vestimenta do hub de um Autônomo soberano (v9) — **única** fonte de kicker/hero/nav/ask.
enum AutonomosHubVestment: Equatable {
    case awaiting(Int)
    case live
    case quiet

    /// Precedência (WAVE-007): awaiting (decisões reais) → quiet se pause local sem live/incident
    /// → resolve server signals → quiet.
    static func resolve(
        backlog: AtlasAutonomosBacklogResponse?,
        live: AtlasAutonomosLiveResponse?,
        incidentPresent: Bool,
        unitPaused: Bool = false
    ) -> AutonomosHubVestment {
        let decisions: Int = {
            guard let backlog else { return 0 }
            return backlog.inboxItems.filter(\.decisionRequired).count
                + backlog.workOrders.filter(\.operatorDecisionRequired).count
        }()
        if decisions > 0 { return .awaiting(decisions) }
        if unitPaused, live?.isRunning != true, !incidentPresent {
            return .quiet
        }
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

    /// WAVE-025 product face word (align with presence vocabulary style).
    var productWord: String {
        switch self {
        case .awaiting: return "awaiting"
        case .live: return "live"
        case .quiet: return "quiet"
        }
    }

    var spokenFace: String {
        switch self {
        case .awaiting(let n):
            return n == 1 ? "pede 1 decisão" : "pede \(n) decisões"
        case .live:
            return "vivo"
        case .quiet:
            return "parado"
        }
    }

    /// List index (no backlog wire): pause local → quiet; else live catalog.
    static func listFace(unitPaused: Bool) -> AutonomosHubVestment {
        unitPaused ? .quiet : .live
    }
}
