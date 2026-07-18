import SwiftUI
import AtlasCore

// Menu label — peel de ConversationViewChrome+HeaderContinuity.

extension ConversationView {
    var continuityMenuLabel: some View {
        Image(systemName: "ellipsis")
            .atlasSans(15, .semibold).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 40, height: 40).atlasGlassCircle()
    }
}
