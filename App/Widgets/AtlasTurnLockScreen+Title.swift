import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Título + badges — peel de LockScreenView.
// Phase → AtlasTurnLockScreen+Phase.swift
// Queue → AtlasTurnLockScreen+QueueCapsule.swift
// Sessions → AtlasTurnLockScreen+Title+SessionsBadge.swift

extension LockScreenView {
    var titleBadges: some View {
        HStack(spacing: 7) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            activeSessionsBadge
            queueCapsule
        }
    }
}
