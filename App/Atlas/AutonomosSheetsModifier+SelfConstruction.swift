import SwiftUI
import AtlasCore

// Self-construction receipt sheet — peel de AutonomosSheetsModifier+Detail.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func selfConstructionSheet(receipt: SelfConstructionReceipt) -> some View {
        SelfConstructionReceiptSheet(
            receipt: receipt,
            canRevert: canRevert(receipt),
            revertReceipt: revertReceipt(receipt)
        ) { actor, reason in
            Task {
                await model.revertCycle(
                    cycle: String(receipt.cycle.cycleIndex),
                    operatorActor: actor,
                    reason: reason
                )
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
