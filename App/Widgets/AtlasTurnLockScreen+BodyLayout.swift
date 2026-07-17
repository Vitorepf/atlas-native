import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock screen layout — peel de AtlasTurnLockScreen.
// Leading → AtlasTurnLockScreen+BodyLayoutLeading.swift

extension LockScreenView {
    @ViewBuilder
    var lockScreenBody: some View {
        HStack(spacing: 14) {
            lockScreenLeadingColumn
            Spacer()
            trailingStatus
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
    }
}
