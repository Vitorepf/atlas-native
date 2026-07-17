import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock progress line — peel de AtlasTurnLockScreen.

extension LockScreenView {
    @ViewBuilder
    var progressLine: some View {
        if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
