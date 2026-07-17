import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Active timer — peel de AtlasTurnLockScreen+Trailing.

extension LockScreenView {
    var trailingTimer: some View {
        AtlasTurnWidgetTimer(
            startedAt: context.state.startedAt,
            paused: context.state.paused,
            pausedDisplay: context.state.pausedDisplay,
            fontSize: 15,
            frameWidth: 52
        )
    }
}
