import SwiftUI
import AtlasCore

// Revert task — peel de AutonomosSheetsModifier+SelfConstruction.

extension AutonomosSheetsModifier {
    func selfConstructionRevertTask(
        receipt: SelfConstructionReceipt,
        actor: String,
        reason: String
    ) {
        Task {
            await model.revertCycle(
                cycle: String(receipt.cycle.cycleIndex),
                operatorActor: actor,
                reason: reason
            )
        }
    }
}
