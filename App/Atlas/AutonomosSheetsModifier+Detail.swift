import SwiftUI
import AtlasCore

// Transfer + detail + self-construction sheets — peel de AutonomosSheetsModifier.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func detailSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showTransferSheet) {
                AutonomosTransferSheet(
                    areaName: model.selectedArea?.areaName ?? "",
                    focus: model.selectedArea?.focus ?? "",
                    placement: model.live?.runtimePlacement
                ) { actor, reason in
                    Task { await model.transfer(operatorActor: actor, reason: reason) }
                }
            }
            .sheet(item: $detailSheet) { sheet in
                AutonomosPublicDetailSheet(kind: sheet, backlog: model.backlog)
            }
            .sheet(item: $selfConstructionReceipt) { receipt in
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
}
