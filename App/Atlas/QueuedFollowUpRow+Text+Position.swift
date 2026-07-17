import SwiftUI

// Position caption — peel de QueuedFollowUpRow+Text.

extension QueuedFollowUpRow {
    @ViewBuilder
    var rowPositionCaption: some View {
        if total > 1 {
            Text(positionCaption)
                .font(AtlasFont.mono(10))
                .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
