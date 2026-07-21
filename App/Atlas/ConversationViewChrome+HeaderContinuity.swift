import SwiftUI
import AtlasCore

// Continuity menu — peel de ConversationViewChrome+HeaderTrailing.
// Actions → ConversationViewChrome+HeaderContinuity+MenuActions.swift
// Label → ConversationViewChrome+HeaderContinuity+MenuLabel.swift

extension ConversationView {
    @ViewBuilder
    var continuityMenu: some View {
        Menu {
            continuityMenuActions
        } label: {
            continuityMenuLabel
        }
        .accessibilityLabel(ConversationViewA11y.headerContinuityLabel)
        .accessibilityHint(ConversationViewA11y.headerContinuityHint)
        .accessibilityIdentifier(A11yID.conversationHeaderContinuity)
    }
}
