import SwiftUI
import AtlasCore

// Menu label — peel de ConversationViewChrome+HeaderContinuity.

extension ConversationView {
    var continuityMenuLabel: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
    }
}
