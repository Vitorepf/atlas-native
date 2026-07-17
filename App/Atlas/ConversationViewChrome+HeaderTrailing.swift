import SwiftUI
import AtlasCore

// Continuity menu — peel de ConversationViewChrome+Header.
// Continuity → ConversationViewChrome+HeaderContinuity.swift

extension ConversationView {
    @ViewBuilder
    var headerTrailing: some View {
        if model.threadId != nil {
            HStack(spacing: 8) {
                if !model.bubbles.isEmpty {
                    Button {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        showOutline = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.textSecondary)
                            .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
                    }
                    .accessibilityLabel(ConversationViewA11y.spokenOutlineLabel(turnCount: model.bubbles.count))
                    .accessibilityHint(ConversationViewA11y.outlineHint)
                    .accessibilityIdentifier(A11yID.conversationOutline)
                }
                continuityMenu
            }
        } else {
            Color.clear.frame(width: 40, height: 40)
                .accessibilityHidden(true)
        }
    }
}
