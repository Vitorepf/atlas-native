import SwiftUI
import AtlasCore

// Detail item sheets — peel de AutonomosSheetsModifier+Detail.

extension AutonomosSheetsModifier {
    @ViewBuilder
    func detailItemSheetsBind<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $detailSheet) { sheet in
                AutonomosPublicDetailSheet(kind: sheet, backlog: model.backlog)
            }
            .sheet(item: $selfConstructionReceipt) { receipt in
                selfConstructionSheet(receipt: receipt)
            }
    }
}
