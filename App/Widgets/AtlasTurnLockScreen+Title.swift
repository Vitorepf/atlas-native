import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Título + badges — peel de LockScreenView.
// Phase → AtlasTurnLockScreen+Phase.swift

extension LockScreenView {
    var titleBadges: some View {
        HStack(spacing: 7) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            if context.state.activeSessions > 1 {
                Text("× \(context.state.activeSessions)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.gold)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Capsule().fill(Ink.gold.opacity(0.14)))
            }
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
}
