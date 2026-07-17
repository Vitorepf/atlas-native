import SwiftUI
import AtlasCore

// Conversation header — peel de ConversationViewChrome.
// Trailing → ConversationViewChrome+HeaderTrailing.swift

extension ConversationView {
    var header: some View {
        HStack(spacing: 12) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
            headerTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }
}
