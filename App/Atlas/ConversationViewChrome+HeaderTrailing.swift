import SwiftUI
import AtlasCore

// Continuity menu — peel de ConversationViewChrome+Header.
// Continuity → ConversationViewChrome+HeaderContinuity.swift
// Outline → ConversationViewChrome+HeaderOutline.swift

extension ConversationView {
    @ViewBuilder
    var headerTrailing: some View {
        if model.threadId != nil {
            HStack(spacing: 8) {
                outlineHeaderButton
                continuityMenu
            }
        } else {
            Color.clear.frame(width: 40, height: 40)
                .accessibilityHidden(true)
        }
    }
}
