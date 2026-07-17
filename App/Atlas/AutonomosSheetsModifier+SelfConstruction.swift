import SwiftUI
import AtlasCore

// Self-construction receipt sheet — peel de AutonomosSheetsModifier+Detail.
// Presentation → AutonomosSheetsModifier+SelfConstruction+Presentation.swift

extension AutonomosSheetsModifier {
    @ViewBuilder
    func selfConstructionSheet(receipt: SelfConstructionReceipt) -> some View {
        selfConstructionPresentation(
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
        )
    }
}
