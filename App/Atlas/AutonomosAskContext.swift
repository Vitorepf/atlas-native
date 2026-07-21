import Foundation
import AtlasCore

// GOD-RESTRUCTURE: AutonomosAskContext + Organs* fused

// MARK: - Host pack

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

        // WAVE-184: unit focus pack (charter · local catalog · age).
        let unitPack = AutonomosListJudgment.packUnitFocusFacts(unit: unit)
        facts.append(contentsOf: unitPack.facts)
        absences.append(contentsOf: unitPack.absences)
        anchors.append(contentsOf: unitPack.anchors)
        if unit == nil {
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
// MARK: - Organs · global

extension AutonomosAskContext {
    // MARK: - Global loop · bind · transfer · health · fleet
    static func appendGlobalOrgans(
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?,
        lastControlReceipt: AtlasAutonomosRunControlResponse?,
        lastTransferReceipt: AtlasAutonomosTransferResponse?,
        taskHealth: AtlasAutonomosTaskHealthResponse?,
        areaSelected: Bool,
        fleet: AtlasAutonomosFleetResponse?,
        digest: AtlasAutonomosDigestResponse?,
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        into facts: inout [String],
        absences: inout [String],
        anchors: inout [String]
    ) {
        let loop = AutonomosRunControlJudgment.packLoopFacts(
            face: controlFace,
            canControl: canControl,
            live: live,
            receipt: lastControlReceipt
        )
        facts.append(contentsOf: loop.facts)
        absences.append(contentsOf: loop.absences)
        anchors.append("loop · \(controlFace.productWord)")

        if !areas.isEmpty || selectedAreaID != nil {
            let bind = AutonomosAreaBindJudgment.packFacts(
                areas: areas,
                selectedAreaID: selectedAreaID
            )
            facts.append(contentsOf: bind.facts)
            absences.append(contentsOf: bind.absences)
        }

        let transfer = AutonomosTransferJudgment.packFacts(
            canTransfer: AutonomosTransferJudgment.canTransfer(canControlSelectedArea: canControl),
            receipt: lastTransferReceipt
        )
        facts.append(contentsOf: transfer.facts)
        absences.append(contentsOf: transfer.absences)

        let health = AutonomosTaskHealthJudgment.packFacts(
            areaSelected: areaSelected,
            health: taskHealth
        )
        facts.append(contentsOf: health.facts)
        absences.append(contentsOf: health.absences)
        if AutonomosTaskHealthJudgment.incidentPresent(taskHealth) {
            anchors.append("incident · present")
        }

        let fleetPack = AutonomosFleetJudgment.packFacts(fleet)
        facts.append(contentsOf: fleetPack.facts)
        absences.append(contentsOf: fleetPack.absences)

        let digestPack = AutonomosDigestJudgment.packFacts(digest)
        facts.append(contentsOf: digestPack.facts)
        absences.append(contentsOf: digestPack.absences)
    }
}
// MARK: - Organs · veto

extension AutonomosAskContext {
    // MARK: - Veto · nightly · can_do prep
    static func appendVetoNightlyCanDoOrgans(
        destination: AutonomosDestination?,
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        decisionCount: Int,
        hasUnit: Bool,
        delivered: AtlasAutonomosDeliveredResponse?,
        selfConstructionReceipt: SelfConstructionReceipt?,
        nightlyPending: Bool?,
        nightlyMuted: Bool,
        nightlyAutoPaused: Bool,
        nightlyWorkspaceText: String?,
        nightlyMutedUntil: Date?,
        rhythmWindows: AtlasDayRhythm.Windows? = nil,
        into facts: inout [String],
        absences: inout [String],
        anchors: inout [String]
    ) -> Bool {
        if canControl {
            let reasonPack = AutonomosReasonJudgment.packFacts(
                actionTitle: "controle_loop",
                actor: "",
                reason: "",
                reasonOptional: true
            )
            facts.append(contentsOf: reasonPack.facts)
            absences.append(contentsOf: reasonPack.absences)
            absences.append("reason_sheet: face-only — actor/motivo só no modal governado")
        }

        let mergeReceipt = selfConstructionReceipt
            ?? SelfConstructionVetoJudgment.latestMergeProved(delivered: delivered)
        let vetoPack = SelfConstructionVetoJudgment.packFacts(
            receipt: mergeReceipt,
            canControlSelectedArea: canControl
        )
        facts.append(contentsOf: vetoPack.facts)
        absences.append(contentsOf: vetoPack.absences)
        let canRevert = mergeReceipt.map {
            SelfConstructionVetoJudgment.canRevert(
                receipt: $0,
                canControlSelectedArea: canControl
            )
        } ?? false
        if canRevert {
            anchors.append("veto · merge-proved")
        }

        if destination == nil, let nightlyPending {
            let nightlyPack = NightlyProposalJudgment.packFacts(
                hasPending: nightlyPending,
                isMuted: nightlyMuted,
                autoPaused: nightlyAutoPaused,
                workspaceText: nightlyWorkspaceText,
                mutedUntil: nightlyMutedUntil
            )
            facts.append(contentsOf: nightlyPack.facts)
            absences.append(contentsOf: nightlyPack.absences)
        } else if destination == nil {
            absences.append("nightly organ não snapshot neste turn")
        }

        // WAVE-177: rhythm pack when host awaited windows (catalog only).
        if destination == nil {
            if let rhythmWindows {
                let rhythmPack = AutonomosRhythmJudgment.packFacts(
                    windows: rhythmWindows,
                    paused: nightlyMuted
                )
                facts.append(contentsOf: rhythmPack.facts)
                absences.append(contentsOf: rhythmPack.absences)
            } else {
                absences.append(
                    "ritmo: host não passou windows — pack não inventa sample"
                )
            }
        }
        return canRevert
    }

}
// MARK: - Organs · destination

extension AutonomosAskContext {
    // MARK: - Destination drill
    static func appendDestinationOrgans(
        unit: AutonomosUnit?,
        destination: AutonomosDestination?,
        backlog: AtlasAutonomosBacklogResponse?,
        subjects: [String],
        decisionCount: Int,
        controlFace: AutonomosRunControlFace,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?,
        taskHealth: AtlasAutonomosTaskHealthResponse?,
        lastControlReceipt: AtlasAutonomosRunControlResponse?,
        lastTransferReceipt: AtlasAutonomosTransferResponse?,
        delivered: AtlasAutonomosDeliveredResponse?,
        cycles: AtlasAutonomosCyclesResponse?,
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        into facts: inout [String],
        absences: inout [String],
        anchors: inout [String]
    ) {
        if let destination {
            facts.append("tela: \(destination.navTitle)")
            anchors.append("dest: \(destination.navTitle)")
            switch destination {
            case .hub:
                facts.append("foco: hub do Autônomo — saúde e atalhos locais")
                // WAVE-179: decision face pack (not hand-roll count only).
                let decisionPack = AutonomosDecisionJudgment.packFacts(
                    backlog: backlog,
                    areaSelected: selectedAreaID != nil || canControl,
                    error: nil
                )
                facts.append(contentsOf: decisionPack.facts)
                absences.append(contentsOf: decisionPack.absences)
                for title in subjects.prefix(5) {
                    anchors.append("decision:\(title)")
                }
                if let unit {
                    let hubPack = AutonomosHubJudgment.packFacts(
                        unitName: unit.name,
                        vestment: AutonomosHubVestment.resolve(
                            backlog: backlog,
                            live: live,
                            incidentPresent: AutonomosTaskHealthJudgment.incidentPresent(taskHealth),
                            unitPaused: unit.paused
                        ),
                        controlFace: controlFace,
                        needsAreaBind: AutonomosAreaBindJudgment.face(
                            areas: areas,
                            selectedAreaID: selectedAreaID
                        ).needsChooser,
                        canTransfer: AutonomosTransferJudgment.canTransfer(
                            canControlSelectedArea: canControl
                        ),
                        hasControlReceipt: lastControlReceipt != nil,
                        hasTransferReceipt: lastTransferReceipt != nil,
                        controlApplied: lastControlReceipt?.applied
                    )
                    facts.append(contentsOf: hubPack.facts)
                    absences.append(contentsOf: hubPack.absences)
                }
            case .decisions, .decisionInbox, .decisionOrder:
                facts.append("foco: decisões")
                // WAVE-179: one law with surface face.
                let decisionPack = AutonomosDecisionJudgment.packFacts(
                    backlog: backlog,
                    areaSelected: true,
                    error: nil
                )
                facts.append(contentsOf: decisionPack.facts)
                absences.append(contentsOf: decisionPack.absences)
                for title in subjects.prefix(5) {
                    anchors.append("decision:\(title)")
                }
            case .evolution:
                facts.append("foco: evolução")
                let evo = AutonomosEvolutionJudgment.packFacts(
                    marcos: AutonomosEvolutionJudgment.marcos(delivered: delivered, cycles: cycles)
                )
                facts.append(contentsOf: evo.facts)
                absences.append(contentsOf: evo.absences)
            case .moment:
                facts.append("foco: digest/momento — janela provider-safe")
            case .incident:
                facts.append("foco: incidente — só sinais reais da face")
            }
        } else {
            facts.append("tela: catálogo do operador")
        }
    }

}
