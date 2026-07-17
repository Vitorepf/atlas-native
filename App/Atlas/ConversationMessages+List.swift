import SwiftUI
import AtlasCore

// Empty + bubbles LazyVStack — peel de ConversationMessages (régua ≤100).
// Rows → ConversationMessages+Rows.swift

extension ConversationMessages {
    @ViewBuilder
    func messagesList() -> some View {
        if model.bubbles.isEmpty {
            emptyMessages()
        } else {
            LazyVStack(alignment: .leading, spacing: 40) {
                ForEach(model.bubbles) { bubble in
                    if bubble.id == model.firstNewBubbleId {
                        NewSinceLastVisitMarker()
                            .id("new-since-last-visit")
                    }
                    bubbleRow(bubble)
                    changeReviewChip(for: bubble)
                }
                Color.clear.frame(height: 96).id("bottom")
                    .background(GeometryReader { geo in
                        Color.clear.preference(key: BottomDistanceKey.self,
                                               value: geo.frame(in: .global).minY)
                    })
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationMessagesA11y.spokenMessages(turnCount: model.bubbles.count))
        }
    }
}
