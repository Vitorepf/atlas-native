import Foundation
import AtlasCore

// MARK: - Self-construction retroactive veto (WAVE-033)

/// Pure judgment: when merge-proved receipt may expose veto-with-receipt UI.
enum SelfConstructionVetoJudgment {

    /// Product word for a11y / pack.
    static let productWord = "veto"

    static let spokenFace = "veto retroativo com recibo"

    /// Merge-proved + area can accept control writes.
    static func canRevert(
        receipt: SelfConstructionReceipt,
        canControlSelectedArea: Bool
    ) -> Bool {
        receipt.hasMergeProof && canControlSelectedArea
    }

    /// Path key for `revertAutonomosCycle(cycle:)` — cycleIndex is the
    /// only stable public index on `AtlasAutonomosCycle` (no cycleId DTO).
    static func cycleKey(for cycle: AtlasAutonomosCycle) -> String {
        String(cycle.cycleIndex)
    }

    static func cycleKey(for receipt: SelfConstructionReceipt) -> String {
        cycleKey(for: receipt.cycle)
    }

    /// Silence reasons for pack / empty veto.
    static func absences(
        receipt: SelfConstructionReceipt?,
        canControlSelectedArea: Bool
    ) -> [String] {
        var out: [String] = []
        guard let receipt else {
            out.append("sem recibo de auto-construção merge-proved neste recorte")
            return out
        }
        if !receipt.hasMergeProof {
            out.append("ciclo sem merge comprovado — veto theater proibido")
        }
        if !canControlSelectedArea {
            out.append("área não controlável — selectArea/registered pendente para revertCycle")
        }
        return out
    }

    // MARK: Pack (WAVE-159)

    /// Pack organ for merge-proved self-construction + veto CTA honesty.
    static func packFacts(
        receipt: SelfConstructionReceipt?,
        canControlSelectedArea: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        let absences = SelfConstructionVetoJudgment.absences(
            receipt: receipt,
            canControlSelectedArea: canControlSelectedArea
        )
        guard let receipt else {
            return (facts, absences)
        }
        facts.append("self_construction_face: \(productWord)")
        facts.append("self_construction_merge_proved: \(receipt.hasMergeProof ? "yes" : "no")")
        if !receipt.cycle.mergeHash.isEmpty {
            facts.append("self_construction_merge_hash: \(receipt.cycle.mergeHash)")
        }
        facts.append("self_construction_cycle: \(cycleKey(for: receipt))")
        let can = canRevert(receipt: receipt, canControlSelectedArea: canControlSelectedArea)
        facts.append("can_revert: \(can ? "yes" : "no")")
        if can {
            facts.append("veto_cta: face_only — sheet de recibo (NL não reverte)")
        }
        return (facts, absences)
    }

    /// Latest merge-proved receipt from published delivered cycles (never invent).
    static func latestMergeProved(
        delivered: AtlasAutonomosDeliveredResponse?
    ) -> SelfConstructionReceipt? {
        guard let cycles = delivered?.delivered else { return nil }
        guard let cycle = cycles.first(where: { $0.mergePerformed && !$0.mergeHash.isEmpty }) else {
            return nil
        }
        return SelfConstructionReceipt(cycle: cycle, finding: nil)
    }
}
