import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Título + badges — peel de LockScreenView.
// Phase → AtlasTurnLockScreen+Phase.swift
// Queue → AtlasTurnLockScreen+QueueCapsule.swift

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
            queueCapsule
        }
    }
}
