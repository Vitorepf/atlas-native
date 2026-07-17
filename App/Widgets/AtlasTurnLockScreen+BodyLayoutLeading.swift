import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock leading column — peel de AtlasTurnLockScreen+BodyLayout.

extension LockScreenView {
    @ViewBuilder
    var lockScreenLeadingColumn: some View {
        Text(context.state.atlasSymbol)
            .font(.system(size: 28, design: .serif))
            .foregroundStyle(context.state.atlasColor)
            .shadow(color: context.state.atlasColor.opacity(0.35), radius: 4)
        VStack(alignment: .leading, spacing: 3) {
            titleBadges
            phaseLine
            progressLine
        }
    }
}
