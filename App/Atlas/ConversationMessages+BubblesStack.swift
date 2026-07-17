import SwiftUI
import AtlasCore

// Messages LazyVStack — peel de ConversationMessages+List.

extension ConversationMessages {
    var bubblesStack: some View {
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
