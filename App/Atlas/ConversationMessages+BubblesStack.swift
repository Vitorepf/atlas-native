import SwiftUI
import AtlasCore

// Messages LazyVStack — peel de ConversationMessages+List.
// A11y → ConversationMessages+BubblesA11y.swift

extension ConversationMessages {
    var bubblesStack: some View {
        bubblesStackA11y(
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
        )
    }
}
