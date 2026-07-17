import SwiftUI
import AtlasCore

// Kind badge — peel de ExecutionStateCard+Header.

extension ExecutionStateCard {
    @ViewBuilder
    var stateHeaderBadge: some View {
        if let badge = kindBadge {
            Text(badge)
                .font(AtlasFont.mono(10)).tracking(0.8)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
    }
}
