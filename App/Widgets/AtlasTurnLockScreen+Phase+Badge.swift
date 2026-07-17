import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Phase badge — peel de AtlasTurnLockScreen+Phase.
// Chrome → AtlasTurnLockScreen+Phase+Badge+Chrome.swift

extension LockScreenView {
    @ViewBuilder
    var phaseBadgeChip: some View {
        if let badge = context.state.phaseBadge {
            phaseBadgeChrome(badge)
        }
    }
}
