import SwiftUI
import AtlasCore

// Self-construction receipt sheet — peel de AutonomosSheetsModifier+Detail.
// RevertTask → AutonomosSheetsModifier+SelfConstruction+RevertTask.swift

extension AutonomosSheetsModifier {
    @ViewBuilder
    func selfConstructionSheet(receipt: SelfConstructionReceipt) -> some View {
        selfConstructionPresentation(
            SelfConstructionReceiptSheet(
                receipt: receipt,
                canRevert: canRevert(receipt),
                revertReceipt: revertReceipt(receipt)
            ) { actor, reason in
                selfConstructionRevertTask(receipt: receipt, actor: actor, reason: reason)
            }
        )
    }
}
