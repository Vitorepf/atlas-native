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
}
