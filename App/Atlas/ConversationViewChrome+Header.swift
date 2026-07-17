import SwiftUI
import AtlasCore

// Conversation header — peel de ConversationViewChrome.

extension ConversationView {
    var header: some View {
        HStack(spacing: 12) {
            Button {
                if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")
            .accessibilityHint("fecha a conversa")
            Spacer(minLength: 0)
            Text(title).font(AtlasFont.serif(17, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(title)
            Spacer(minLength: 0)
            if model.threadId != nil {
                HStack(spacing: 8) {
                    if !model.bubbles.isEmpty {
                        Button {
                            if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
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
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }
}
