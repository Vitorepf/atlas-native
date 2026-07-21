import Foundation
import AtlasCore

// WAVE-172 density peel — Autonomos pack veto/nightly organs

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
