import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock trailing timer/check — peel de AtlasTurnLockScreen.
// Finished → AtlasTurnLockScreen+Trailing+Finished.swift
// Timer → AtlasTurnLockScreen+Trailing+Timer.swift

extension LockScreenView {
    @ViewBuilder
    var trailingStatus: some View {
        if context.state.finished {
            trailingFinished
        } else {
            trailingTimer
        }
    }
}
