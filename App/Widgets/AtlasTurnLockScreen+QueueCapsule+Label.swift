import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Queue label text — peel de AtlasTurnLockScreen+QueueCapsule.

extension LockScreenView {
    @ViewBuilder
    func queueCapsuleLabel(_ queued: String) -> some View {
        Text(queued)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(Ink.gold)
            .accessibilityLabel(queued)
    }
}
