import SwiftUI
import AtlasCore

// Cycle list — peel de AutonomosAreaDeliveredSection+Filled.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredFilledCycleList(
        delivered: AtlasAutonomosDeliveredResponse,
        visible: Int,
        isSelf: Bool
    ) -> some View {
        ForEach(Array(delivered.delivered.prefix(AutonomosAreaDeliveredA11y.visibleCap).enumerated()), id: \.element.id) { index, cycle in
            deliveredCycleRow(cycle: cycle, index: index, visible: visible, isSelf: isSelf)
        }
    }
}
