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
        // "há 6 semanas" no lugar do ISO cru; sem parse, o cru ainda é verdade.
        Text(AtlasTime.date(cycle.recordedAt).map { "há \(AutonomosChrome.relativeAge(from: $0))" } ?? cycle.recordedAt)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            .lineLimit(1)
    }
}
