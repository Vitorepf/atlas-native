import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock trailing timer/check — peel de AtlasTurnLockScreen.

extension LockScreenView {
    @ViewBuilder
    var trailingStatus: some View {
        if context.state.finished {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22)).foregroundStyle(Ink.healed)
        } else {
            AtlasTurnWidgetTimer(
                startedAt: context.state.startedAt,
                paused: context.state.paused,
                pausedDisplay: context.state.pausedDisplay,
                fontSize: 15,
                frameWidth: 52
            )
        }
    }
}
