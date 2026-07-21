import SwiftUI
import AtlasCore

// Separator — peel de ConversationComposer+LiveStrip.

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSeparator: some View {
        Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
            .padding(.bottom, expanded ? 0 : 8)
            .accessibilityHidden(true)
    }
}
