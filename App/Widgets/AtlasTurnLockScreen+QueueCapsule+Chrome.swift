import SwiftUI
import WidgetKit

// Queue capsule chrome — peel de AtlasTurnLockScreen+QueueCapsule.

extension LockScreenView {
    func queueCapsuleChrome<Label: View>(_ label: Label) -> some View {
        label
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(Ink.gold.opacity(0.22)))
            .overlay(Capsule().stroke(Ink.gold.opacity(0.45), lineWidth: 0.5))
    }
}
