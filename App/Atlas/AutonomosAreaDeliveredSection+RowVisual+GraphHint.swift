import SwiftUI
import AtlasCore

// Graph hint + timestamp — peel de AutonomosAreaDeliveredSection+RowVisual.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredRowGraphHint(_ cycle: AtlasAutonomosCycle, graphHint: Bool) -> some View {
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
}
