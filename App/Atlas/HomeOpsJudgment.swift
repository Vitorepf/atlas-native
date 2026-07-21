import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Autônomos door face on Home OPERAÇÃO (WAVE-047).
enum HomeOpsAutonomosFace: Equatable {
    case unbound
    case quiet
    case fleetPressure(Int)
    case liveLoop
    case incident
    case awaiting(Int)

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .quiet: return "quiet"
        case .fleetPressure: return "fleet_pressure"
        case .liveLoop: return "live"
        case .incident: return "incident"
        case .awaiting: return "awaiting"
        }
    }

    var spokenMeta: String {
        switch self {
        case .unbound:
            return "Autônomos, abre catálogo de escopos soberanos"
        case .quiet:
            return "Autônomos, quieto"
        case .fleetPressure(let n):
            return n == 1
                ? "Autônomos, 1 agente pede atenção"
                : "Autônomos, \(n) agentes pedem atenção"
        case .liveLoop:
            return "Autônomos, loop ao vivo"
        case .incident:
            return "Autônomos, incidente publicado"
        case .awaiting(let n):
            return n == 1
                ? "Autônomos, pede 1 decisão"
                : "Autônomos, pede \(n) decisões"
        }
    }

    var rowMeta: String? {
        switch self {
        case .unbound, .quiet: return nil
        case .fleetPressure(let n): return n == 1 ? "1 atenção" : "\(n) atenção"
        case .liveLoop: return "ao vivo"
        case .incident: return "incidente"
        case .awaiting(let n): return n == 1 ? "1 decisão" : "\(n) decisões"
        }
    }
}

/// Arena door face — no regression badge on Home.
enum HomeOpsArenaFace: Equatable {
    case available
    case domainUnavailable

    var productWord: String {
        switch self {
        case .available: return "available"
        case .domainUnavailable: return "domain_unavailable"
        }
    }

    @MainActor
    var spoken: String {
        switch self {
        case .available:
            return "Arena, abre medição de regressão"
        case .domainUnavailable:
            return "Arena, \(ArenaModel.domainUnavailableCopy)"
        }
    }
}

// MARK: - Judgment

/// Pure Home OPERAÇÃO attention — Autônomos + Arena door only.
enum HomeOpsJudgment {

    @MainActor
    static func autonomosFace(model: AutonomosModel) -> HomeOpsAutonomosFace {
        // Unbound only before any ops hydrate (no areas + no global organs).
        if model.areas.isEmpty,
           model.backlog == nil,
           model.live == nil,
           model.taskHealth == nil,
           model.fleet == nil {
            return .unbound
        }

        let awaiting = AutonomosDecisionJudgment.decisionCount(from: model.backlog)
        if awaiting > 0 {
            return .awaiting(awaiting)
        }

        if AutonomosTaskHealthJudgment.incidentPresent(model.taskHealth) {
            return .incident
        }

        if model.live?.isRunning == true {
            return .liveLoop
        }

        let fleetFace = AutonomosFleetJudgment.face(from: model.fleet)
        if case .attention(let n) = fleetFace {
            return .fleetPressure(n)
        }

        return .quiet
    }

    static func arenaFace(domainUnavailable: Bool) -> HomeOpsArenaFace {
        domainUnavailable ? .domainUnavailable : .available
    }

    // MARK: Catalog shell (WAVE-184)

    /// Home partida catalog — threads known + workspace names (never invents frota).
    static func packCatalogFacts(
        threadCount: Int,
        workspaceNames: [String]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("home_threads_known: \(threadCount)")
        if workspaceNames.isEmpty {
            absences.append("nenhum workspace listado")
        } else {
            facts.append(
                "home_workspaces: \(workspaceNames.prefix(8).joined(separator: ", "))"
            )
        }
        absences.append("não invente contagens de frota/Arena sem a superfície correspondente")
        return (facts, absences)
    }

    @MainActor
    static func packFacts(session: AtlasSession) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let auto = session.autonomos
        let face = autonomosFace(model: auto)
        facts.append("home_ops_autonomos_face: \(face.productWord)")
        facts.append(face.spokenMeta)

        if auto.areas.isEmpty {
            absences.append("áreas Autônomos não hidratadas na porta Home")
        } else {
            facts.append("autonomos_areas: \(auto.areas.count)")
        }
        if auto.backlog == nil {
            absences.append("backlog de decisões não hidratado na Home — sem inventar awaiting")
        } else {
            facts.append("awaiting_decisions: \(AutonomosDecisionJudgment.decisionCount(from: auto.backlog))")
        }
        if auto.taskHealth == nil {
            absences.append("taskHealth não hidratado na Home")
        } else {
            facts.append(
                "incident_present: \(AutonomosTaskHealthJudgment.incidentPresent(auto.taskHealth))"
            )
        }
        if auto.fleet == nil {
            absences.append("fleet global não hidratado na Home")
        } else {
            facts.append("fleet_face: \(AutonomosFleetJudgment.face(from: auto.fleet).productWord)")
        }

        let arena = arenaFace(domainUnavailable: session.arena.isDomainUnavailable)
        facts.append("home_ops_arena_face: \(arena.productWord)")
        facts.append(arena.spoken)
        // Explicit: no regression invent on Home door.
        absences.append("regressão da Arena não eleva na Home (ordem 2026-07-18)")

        return (facts, absences)
    }

    // MARK: Profile spoken (WAVE-104)

    static let operatorProfileSpoken = "Vitor, operador do Atlas"

    static func spokenProfileLine(label: String, value: String) -> String {
        "\(label), \(value)"
    }

}
