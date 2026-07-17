import SwiftUI
import AtlasCore

// Messages LazyVStack — peel de ConversationMessages+List.
// Bottom → ConversationMessages+BubblesBottom.swift
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
                bubblesBottomAnchor
            }
        )
    }
}
