import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Phase line — peel de AtlasTurnLockScreen+Title.
// Badge → AtlasTurnLockScreen+Phase+Badge.swift

extension LockScreenView {
    var phaseLine: some View {
        HStack(spacing: 6) {
            phaseBadgeChip
            Text(context.state.phaseTitle)
                .font(.system(size: 13, design: .serif)).italic()
                .foregroundStyle(context.state.finished ? Ink.healed : context.state.atlasColor.opacity(0.88))
                .lineLimit(1)
        }
    }
}
