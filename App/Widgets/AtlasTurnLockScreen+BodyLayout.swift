import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock screen layout — peel de AtlasTurnLockScreen.

extension LockScreenView {
    @ViewBuilder
    var lockScreenBody: some View {
        HStack(spacing: 14) {
            Text(context.state.atlasSymbol)
                .font(.system(size: 28, design: .serif))
                .foregroundStyle(context.state.atlasColor)
                .shadow(color: context.state.atlasColor.opacity(0.35), radius: 4)
            VStack(alignment: .leading, spacing: 3) {
                titleBadges
                phaseLine
                progressLine
            }
            Spacer()
            trailingStatus
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
    }
}
