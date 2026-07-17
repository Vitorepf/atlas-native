import SwiftUI
import AtlasCore

// Transfer sheet — peel de AutonomosSheetsModifier+Detail.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func transferSheetBind<Content: View>(on content: Content) -> some View {
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
    }
}
