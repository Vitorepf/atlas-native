import SwiftUI
import AtlasCore

// Outline button — peel de ConversationViewChrome+HeaderTrailing.

extension ConversationView {
    @ViewBuilder
    var outlineHeaderButton: some View {
        if !model.bubbles.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                showOutline = true
            } label: {
                Image(systemName: "list.bullet.rectangle")
                    .atlasSans(15, .semibold).foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 40, height: 40).atlasGlassCircle()
            }
            .accessibilityLabel(ConversationViewA11y.spokenOutlineLabel(turnCount: model.bubbles.count))
            .accessibilityHint(ConversationViewA11y.outlineHint)
            .accessibilityIdentifier(A11yID.conversationOutline)
        }
    }
}
