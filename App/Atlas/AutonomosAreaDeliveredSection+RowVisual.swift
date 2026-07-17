import SwiftUI
import AtlasCore

// Visual da row entregue — peel de AutonomosAreaDeliveredSection+Row.

extension AutonomosAreaDeliveredSection {
    func deliveredRow(_ cycle: AtlasAutonomosCycle, graphHint: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
            Text(String(cycle.mergeHash.prefix(8))).font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
            if graphHint {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
            }
            Spacer()
            Text(cycle.recordedAt).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }
}
