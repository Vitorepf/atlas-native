import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock queue capsule — peel de AtlasTurnLockScreen+Title.

extension LockScreenView {
    @ViewBuilder
    var queueCapsule: some View {
        // M87 / E-A5: fila N como cápsula gold distinta no título
        if let queued = context.state.queueLabel {
            Text(queued)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Ink.gold.opacity(0.22)))
                .overlay(Capsule().stroke(Ink.gold.opacity(0.45), lineWidth: 0.5))
                .accessibilityLabel(queued)
        }
    }
}
