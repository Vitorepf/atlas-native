import SwiftUI
import AtlasCore

// Open button label — peel de AutonomosAreaDeliveredSection+RowGraph+OpenButton.

extension AutonomosAreaDeliveredSection {
    func deliveredGraphOpenLabel(cycle: AtlasAutonomosCycle) -> some View {
        deliveredRow(cycle, graphHint: true)
    }
}
