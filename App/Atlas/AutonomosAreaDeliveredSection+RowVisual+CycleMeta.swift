import SwiftUI
import AtlasCore

// Cycle meta texts — peel de AutonomosAreaDeliveredSection+RowVisual.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredRowCycleMeta(_ cycle: AtlasAutonomosCycle) -> some View {
        Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
        Text(String(cycle.mergeHash.prefix(8))).font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
    }
}
