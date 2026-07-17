import SwiftUI
import AtlasCore

// Continuity menu — peel de ConversationViewChrome+HeaderTrailing.

extension ConversationView {
    @ViewBuilder
    var continuityMenu: some View {
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
}
