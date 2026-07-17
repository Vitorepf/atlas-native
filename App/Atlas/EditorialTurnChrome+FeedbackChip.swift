import SwiftUI

// Feedback chip button — peel de EditorialTurnChrome+Feedback.
// Label → EditorialTurnChrome+FeedbackChip+Label.swift
// A11y → EditorialTurnChrome+FeedbackChip+A11y.swift

extension FeedbackRow {
    func feedbackChip(_ kind: FeedbackKind) -> some View {
        let isActive = active == kind.activeAction
        return feedbackChipA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onFeedback(kind)
            } label: {
                feedbackChipLabel(kind, isActive: isActive)
            }
            .buttonStyle(PressableScale()),
            kind: kind,
            isActive: isActive
        )
    }
}
