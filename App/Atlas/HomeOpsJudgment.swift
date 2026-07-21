import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: HomeOpsJudgment + HomeAskContext fused

// MARK: - Ops judgment

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

// MARK: - Ask context

enum HomeAskContext {
    static let invite = "Escreva ao Atlas"

    static func emptySuggestions(hasWorkspaces: Bool) -> [String] {
        if hasWorkspaces {
            return [
                "O que está vivo agora?",
                "Abre o grafo do atlas-native",
                "Como está a Arena?"
            ]
        }
        return [
            "O que está vivo agora?",
            "Começa uma conversa livre",
            "O que preciso julgar hoje?"
        ]
    }

    @MainActor
    static func facts(session: AtlasSession) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        let threads = session.threads
        let workspaces = session.workspaces

        // WAVE-184: Home catalog shell (threads · workspaces).
        let catalog = HomeOpsJudgment.packCatalogFacts(
            threadCount: threads.count,
            workspaceNames: workspaces.map(\.name)
        )
        facts.append(contentsOf: catalog.facts)
        absences.append(contentsOf: catalog.absences)

        // WAVE-064: live anchors follow LiveNow attention rank (not wire order).
        // WAVE-183/186: packFacts canon (packLiveAnchors deleted).
        let livePack = LiveNowJudgment.packFacts(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions,
            limit: 5
        )
        facts.append(contentsOf: livePack.facts)
        anchors.append(contentsOf: livePack.anchors)
        absences.append(contentsOf: livePack.absences)

        // WAVE-047: ops door attention only from published Autônomos/Arena signals.
        let ops = HomeOpsJudgment.packFacts(session: session)
        facts.append(contentsOf: ops.facts)
        absences.append(contentsOf: ops.absences)

        // WAVE-084: empty editorial face for Home partida (catalog honesty).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions(hasWorkspaces: !workspaces.isEmpty),
            isHomePartida: true,
            hasWorkspaces: !workspaces.isEmpty
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        // WAVE-158: can_do matrix — never bare readChat hardcode; no stop invent.
        let liveCount = LiveNowJudgment.rank(
            local: TurnPresence.shared.liveSessions,
            remote: session.remoteLiveSessions
        ).count
        let autonomosFace = HomeOpsJudgment.autonomosFace(model: session.autonomos)
        let partida = PartidaCanDoJudgment.home(
            autonomosFace: autonomosFace,
            liveCount: liveCount
        )
        absences.append(contentsOf: partida.absences)

        // WAVE-166: ops failure organ when home load failed empty.
        if threads.isEmpty, case .failed = session.phase {
            let failPack = AtlasOpsFailureJudgment.packFacts(
                mode: .network(
                    kind: session.failureKind,
                    hasToken: session.hasToken,
                    host: session.host
                )
            )
            facts.append(contentsOf: failPack.facts)
            absences.append(contentsOf: failPack.absences)
        }

        // WAVE-170: workspace picker face (catalog doors from Home).
        let pickerPack = WorkspacePickerJudgment.packFacts(
            phase: session.phase,
            repoCount: workspaces.count,
            query: "",
            showsNoRepo: workspaces.isEmpty
        )
        facts.append(contentsOf: pickerPack.facts)
        absences.append(contentsOf: pickerPack.absences)

        return AgenticOccasionPack(
            surface: "home",
            subject: "partida do operador",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }
}
