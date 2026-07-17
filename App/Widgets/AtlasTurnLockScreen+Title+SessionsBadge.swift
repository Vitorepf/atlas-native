import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Active sessions badge — peel de AtlasTurnLockScreen+Title.

extension LockScreenView {
    @ViewBuilder
    var activeSessionsBadge: some View {
        if context.state.activeSessions > 1 {
            Text("× \(context.state.activeSessions)")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .padding(.horizontal, 7).padding(.vertical, 2)
                .background(Capsule().fill(Ink.gold.opacity(0.14)))
        }
    }
}
