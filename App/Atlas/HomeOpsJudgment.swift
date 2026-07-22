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


    // MARK: Home section product faces

    static let productConversasSection = "CONVERSAS"
    static let productOperacaoSection = "OPERAÇÃO"
    static let productWorkspacesSection = "WORKSPACES"
    static let productLiveNowKicker = "VIVO AGORA"
    static let productAuditBadge = "AUDITORIA"
    static let productModoAuditoria = "MODO AUDITORIA"
    static let productAuditModeLabel = "Modo auditoria"

    static let spokenOperatorProfile = "Vitor, operador do Atlas"
    static let spokenSearchHint = "abre busca nas conversas carregadas"
    static let spokenCodeTopBarHint = "abre radar de repositórios"

    static func spokenProfileLine(label: String, value: String) -> String {
        "\(label), \(value)"
    }

}

// MARK: - Ask context

enum HomeAskContext {
    static let productInvite = "Escreva ao Atlas"

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
            prompt: productInvite,
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

// MARK: - Partida can-do

// MARK: - Types

/// WAVE-158: one can_do law for partida doors (Home · Workspace · Radar).
/// Never invents stop/steer/write — those live on conversation / Autônomos faces.
enum PartidaCanDoJudgment {

    struct Result: Equatable {
        let canDo: AgenticOccasionPack.CanDo
        let absences: [String]
    }

    // MARK: Home

    /// Home doors are navigation only. Live/stop/escolher only on open thread.
    static func home(
        autonomosFace: HomeOpsAutonomosFace,
        liveCount: Int
    ) -> Result {
        var absences: [String] = []

        switch autonomosFace {
        case .awaiting:
            absences.append(
                "abrir Autônomos para assinar decisões — NL da Home não decide"
            )
        case .incident:
            absences.append(
                "incidente na frota Autônomos — abrir Autônomos; NL Home não controla loop"
            )
        case .liveLoop:
            absences.append(
                "loop Autônomos ao vivo — controle (pause/kill) só no Hub Autônomos"
            )
        case .fleetPressure:
            absences.append(
                "frota pede atenção — abrir Autônomos; Home só navega"
            )
        case .unbound:
            absences.append("Autônomos ainda unbound — catálogo sem área hidratada")
        case .quiet:
            break
        }

        if liveCount > 0 {
            absences.append(
                "sessoes vivas na Home — stop/escolher/steer só na conversa aberta (não invente cta_only_run_stop aqui)"
            )
        }

        // Nav doors (Autônomos/Arena/Código) are face navigation, not run control.
        // Read chat is the honest pack can_do for partida.
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Workspace

    static func workspace(scopedLiveCount: Int) -> Result {
        var absences: [String] = []
        if scopedLiveCount > 0 {
            absences.append(
                "live neste workspace — controle do run só na thread aberta"
            )
        }
        absences.append("workspace pack é leitura/navegação — sem stop/steer inventados")
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Radar

    /// Heal CTA is on single-repo Code surface, not multi-repo Radar list.
    /// `hasHealFaceCTA` reserved if a local radar heal button is ever published.
    static func radar(
        hasHealFaceCTA: Bool,
        attentionCount: Int
    ) -> Result {
        var absences: [String] = []
        if attentionCount > 0 {
            absences.append(
                "radar com sem-retorno — curar/heal na superfície do repo, não no pack NL do radar"
            )
        }
        if hasHealFaceCTA {
            // Face CTA local published on this radar chrome.
            return Result(canDo: .faceCTALocal, absences: absences)
        }
        absences.append(
            "radar partida = leitura/julgamento; CTAs de cura só com face publicada no repo"
        )
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Search

    /// Search door = read/nav. Opening a thread is navigation, never run control.
    static func search(
        liveInList: Int,
        isOffline: Bool,
        isLoading: Bool
    ) -> Result {
        var absences: [String] = []
        if isLoading {
            absences.append("busca ainda carregando — pack não inventa threads")
        }
        if isOffline {
            absences.append("busca offline — reconecte; NL não inventa catálogo")
        }
        if liveInList > 0 {
            absences.append(
                "threads vivas no recorte — stop/escolher/steer só na conversa aberta"
            )
        }
        absences.append("abrir thread é navegação da face — NL da busca não para run")
        absences.append("search pack = leitura/julgamento do recorte local na sessão")
        return Result(canDo: .readChat, absences: absences)
    }
}
