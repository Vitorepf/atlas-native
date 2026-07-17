import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Phase line — peel de AtlasTurnLockScreen+Title.

extension LockScreenView {
    var phaseLine: some View {
        HStack(spacing: 6) {
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Capsule().fill(Ink.alert.opacity(0.16)))
                    .accessibilityLabel(context.state.phaseTitle)
            }
            Text(context.state.phaseTitle)
                .font(.system(size: 13, design: .serif)).italic()
                .foregroundStyle(context.state.finished ? Ink.healed : context.state.atlasColor.opacity(0.88))
                .lineLimit(1)
        }
    }
}
