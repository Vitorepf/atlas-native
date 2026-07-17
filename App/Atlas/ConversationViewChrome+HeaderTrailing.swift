import SwiftUI
import AtlasCore

// Continuity menu — peel de ConversationViewChrome+Header.

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
                Menu {
                    Button {
                        Task { await model.handoffToSurface(.desktop) }
                    } label: { Label("Continuar no Mac", systemImage: "desktopcomputer") }
                    Button {
                        Task { await model.handoffToSurface(.terminal) }
                    } label: { Label("Continuar no Terminal", systemImage: "terminal") }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
                }
                .accessibilityLabel(ConversationViewA11y.headerContinuityLabel)
                .accessibilityHint(ConversationViewA11y.headerContinuityHint)
                .accessibilityIdentifier(A11yID.conversationHeaderContinuity)
            }
        } else {
            Color.clear.frame(width: 40, height: 40)
                .accessibilityHidden(true)
        }
    }
}
