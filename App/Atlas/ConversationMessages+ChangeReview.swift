import SwiftUI
import AtlasCore

// Change-review chip — peel de ConversationMessages (régua ≤100).
// Gate → ConversationMessages+ChangeReview+Gate.swift
// Button → ConversationMessages+ChangeReview+Button.swift
// Label → ConversationMessages+ChangeReviewLabel.swift

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if showsChangeReviewChip(for: bubble), let trace = bubble.traceId {
            changeReviewChipButton(for: bubble, trace: trace)
        }
    }
}
