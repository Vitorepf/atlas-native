import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Phase badge chrome — peel de AtlasTurnLockScreen+Phase+Badge.

extension LockScreenView {
    func phaseBadgeChrome(_ badge: String) -> some View {
        Text(badge)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(Ink.alert)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Capsule().fill(Ink.alert.opacity(0.16)))
            .accessibilityLabel(context.state.phaseTitle)
    }
}
