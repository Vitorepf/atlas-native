import SwiftUI
import AtlasCore

// Transfer + detail + self-construction sheets — peel de AutonomosSheetsModifier.
// Self → AutonomosSheetsModifier+SelfConstruction.swift

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
                selfConstructionSheet(receipt: receipt)
            }
    }
}
