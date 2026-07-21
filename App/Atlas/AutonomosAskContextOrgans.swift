import Foundation
import AtlasCore

// WAVE-171 density peel — Autônomos pack organs

extension AutonomosAskContext {
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
                if decisionCount > 0 {
                    facts.append("decisoes_publicadas: \(decisionCount)")
                    for title in subjects {
                        facts.append("decisao: \(title)")
                    }
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
                if decisionCount > 0 {
                    facts.append("decisoes_publicadas: \(decisionCount)")
                    for title in subjects {
                        facts.append("decisao: \(title)")
                        anchors.append("decision:\(title)")
                    }
                } else if backlog == nil {
                    absences.append("backlog de decisões não hidratado — não invente inbox")
                } else {
                    absences.append("zero itens com decisionRequired / operatorDecisionRequired")
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

    /// Returns canRevert for can_do elevation.
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

        if destination == nil {
            absences.append(
                "ritmo: janelas async — face RhythmLearningLine carrega sample; pack não inventa windows"
            )
        }
        return canRevert
    }
}
