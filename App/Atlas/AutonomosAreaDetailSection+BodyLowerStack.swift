import SwiftUI
import AtlasCore

// Lower stack — peel de AutonomosAreaDetailSection+Body.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    var areaDetailLowerStack: some View {
        AutonomosAreaDeliveredSection(
            area: area,
            model: model,
            onSelfConstructionReceipt: onSelfConstructionReceipt
        )
        ownedSystemsBlock
        areaControls
    }
}
