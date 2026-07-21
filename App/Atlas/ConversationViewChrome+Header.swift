import SwiftUI
import AtlasCore

// Conversation header — peel de ConversationViewChrome.
// Trailing → ConversationViewChrome+HeaderTrailing.swift
// Back → ConversationViewChrome+HeaderBack.swift

extension ConversationView {
    var header: some View {
        HStack(spacing: 12) {
            if hidesNavigationBack {
                Color.clear.frame(width: 40, height: 40)
            } else {
                headerBackButton
            }
            Spacer(minLength: 0)
            Text(title)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(title)
            Spacer(minLength: 0)
            headerTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }
}
