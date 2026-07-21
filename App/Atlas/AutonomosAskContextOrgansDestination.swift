import Foundation
import AtlasCore

// WAVE-172 density peel — Autonomos pack destination organs

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
