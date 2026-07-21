import Foundation
import AtlasCore

/// Pack de contexto Autônomos — WAVE-020 grammar + WAVE-026 decision subjects.
// MARK: - Host

enum AutonomosAskContext {
    static func invite(destination: AutonomosDestination?, vestment: AutonomosHubVestment) -> String {
        if let destination {
            switch destination {
            case .hub:
                break
            case .decisions:
                return "qual decido primeiro?"
            case .decisionInbox, .decisionOrder:
                return "por que esse valor?"
            case .evolution:
                return "resuma isto"
            case .moment:
                return "por que isto?"
            case .incident:
                return "o que faço?"
            }
        }
        if destination == nil {
            return "o que mudou hoje?"
        }
        switch vestment {
        case .awaiting: return "o que preciso decidir?"
        case .live: return "o que ele fez hoje?"
        case .quiet: return "devo retomar?"
        }
    }

    static func emptySuggestions(destination: AutonomosDestination?) -> [String] {
        switch destination {
        case .decisions, .decisionInbox, .decisionOrder:
            return ["o que bloqueia?", "qual risco aceitar?"]
        case .incident:
            return ["o que quebrou?", "devo transferir?"]
        case .evolution, .moment:
            return ["o que mudou hoje?"]
        case .hub:
            return ["devo retomar?", "o que ele fez?"]
        case nil:
            return ["o que mudou hoje?", "qual Autônomo merece atenção?"]
        }
    }

    static func facts(
        unit: AutonomosUnit?,
        destination: AutonomosDestination?,
        backlog: AtlasAutonomosBacklogResponse? = nil,
        controlFace: AutonomosRunControlFace = .unbound,
        canControl: Bool = false,
        live: AtlasAutonomosLiveResponse? = nil,
        lastControlReceipt: AtlasAutonomosRunControlResponse? = nil,
        delivered: AtlasAutonomosDeliveredResponse? = nil,
        cycles: AtlasAutonomosCyclesResponse? = nil,
        lastTransferReceipt: AtlasAutonomosTransferResponse? = nil,
        taskHealth: AtlasAutonomosTaskHealthResponse? = nil,
        areaSelected: Bool = false,
        fleet: AtlasAutonomosFleetResponse? = nil,
        digest: AtlasAutonomosDigestResponse? = nil,
        areas: [AtlasAutonomosArea] = [],
        selectedAreaID: String? = nil,
        /// WAVE-159: merge-proved self-construction (nil → honest absence).
        selfConstructionReceipt: SelfConstructionReceipt? = nil,
        /// WAVE-159: catalog nightly organ (nil → skip; host passes controller snapshot).
        nightlyPending: Bool? = nil,
        nightlyMuted: Bool = false,
        nightlyAutoPaused: Bool = false,
        nightlyWorkspaceText: String? = nil,
        nightlyMutedUntil: Date? = nil,
        /// WAVE-177: day-rhythm windows from async host (nil → honest absence).
        rhythmWindows: AtlasDayRhythm.Windows? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        if let unit {
            anchors.append("autonomo: \(unit.name)")
            facts.append("carta: \(unit.charter)")
            // WAVE-030: never claim local catalog pause is the server loop.
            facts.append(
                unit.paused
                    ? "catalogo_local: pausado no iPhone (≠ loop servidor)"
                    : "catalogo_local: no iPhone"
            )
            facts.append("idade_local: \(unit.ageLabel)")
        } else {
            absences.append("lista de Autônomos — nenhum aberto")
            // WAVE-090: catalog list face when no unit focused (empty/list honesty).
            let listPack = AutonomosListJudgment.packFacts(units: [], awaitingUnitIDs: [])
            facts.append(contentsOf: listPack.facts)
            absences.append(contentsOf: listPack.absences)
        }

        let subjects = AutonomosDecisionJudgment.packSubjects(from: backlog)
        let decisionCount = AutonomosDecisionJudgment.decisionCount(from: backlog)

        appendGlobalOrgans(
            controlFace: controlFace,
            canControl: canControl,
            live: live,
            lastControlReceipt: lastControlReceipt,
            lastTransferReceipt: lastTransferReceipt,
            taskHealth: taskHealth,
            areaSelected: areaSelected,
            fleet: fleet,
            digest: digest,
            areas: areas,
            selectedAreaID: selectedAreaID,
            into: &facts,
            absences: &absences,
            anchors: &anchors
        )

        appendDestinationOrgans(
            unit: unit,
            destination: destination,
            backlog: backlog,
            subjects: subjects,
            decisionCount: decisionCount,
            controlFace: controlFace,
            canControl: canControl,
            live: live,
            taskHealth: taskHealth,
            lastControlReceipt: lastControlReceipt,
            lastTransferReceipt: lastTransferReceipt,
            delivered: delivered,
            cycles: cycles,
            areas: areas,
            selectedAreaID: selectedAreaID,
            into: &facts,
            absences: &absences,
            anchors: &anchors
        )

        absences.append("create no servidor ainda pendente (§5)")
        absences.append("catálogo local some se o app for morto — não invente frota 24/7 persistida")

        let canRevert = appendVetoNightlyCanDoOrgans(
            destination: destination,
            controlFace: controlFace,
            canControl: canControl,
            decisionCount: decisionCount,
            hasUnit: unit != nil,
            delivered: delivered,
            selfConstructionReceipt: selfConstructionReceipt,
            nightlyPending: nightlyPending,
            nightlyMuted: nightlyMuted,
            nightlyAutoPaused: nightlyAutoPaused,
            nightlyWorkspaceText: nightlyWorkspaceText,
            nightlyMutedUntil: nightlyMutedUntil,
            rhythmWindows: rhythmWindows,
            into: &facts,
            absences: &absences,
            anchors: &anchors
        )

        let canDoPack = AutonomosCanDoJudgment.packFacts(
            destination: destination,
            controlFace: controlFace,
            canControl: canControl,
            decisionCount: decisionCount,
            hasUnit: unit != nil,
            canRevert: canRevert
        )
        facts.append(contentsOf: canDoPack.facts)
        absences.append(contentsOf: canDoPack.absences)

        let subject: String
        if decisionCount > 0, let first = subjects.first {
            subject = unit.map { "Autônomo · \($0.name) · \(first)" }
                ?? "decisões · \(first)"
        } else {
            subject = unit.map { "Autônomo · \($0.name)" } ?? "catálogo Autônomos"
        }

        return AgenticOccasionPack(
            surface: "autonomos",
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDoPack.canDo
        ).render()
    }
}
