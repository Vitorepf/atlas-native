import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Phase badge — peel de AtlasTurnLockScreen+Phase.

extension LockScreenView {
    @ViewBuilder
    var phaseBadgeChip: some View {
        if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(Ink.alert.opacity(0.16)))
                .accessibilityLabel(context.state.phaseTitle)
        }
    }
}
