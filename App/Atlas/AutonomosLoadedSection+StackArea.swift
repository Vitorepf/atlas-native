import SwiftUI
import AtlasCore

// Area detail in loaded stack — peel de AutonomosLoadedSection+Stack.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedAreaDetail: some View {
        if let area = model.selectedArea {
            AutonomosAreaDetailSection(
                area: area,
                model: model,
                control: $control,
                startRunMode: $startRunMode,
                showTransferSheet: $showTransferSheet,
                onOpenDetail: { detailSheet = $0 },
                onSelfConstructionReceipt: { selfConstructionReceipt = $0 }
            )
        }
    }
}
