import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Finished checkmark — peel de AtlasTurnLockScreen+Trailing.

extension LockScreenView {
    var trailingFinished: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 22)).foregroundStyle(Ink.healed)
    }
}
