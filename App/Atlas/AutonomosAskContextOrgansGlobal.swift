import Foundation
import AtlasCore

// WAVE-172 density peel — Autonomos pack global organs

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
