import SwiftUI
import AtlasCore

// Conversation header — peel de ConversationViewChrome.

extension ConversationView {
    var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            Spacer()
            Text(title).font(AtlasFont.serif(17, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            Spacer()
            if model.threadId != nil {
                Menu {
                    Button { showOutline = true } label: {
                        Label("Índice da conversa", systemImage: "list.bullet.rectangle")
                    }
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
                .accessibilityLabel("continuar esta conversa em outra superfície")
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }
}
