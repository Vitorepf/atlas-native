import SwiftUI
import AtlasCore

// Signature + feedback — peel de EditorialTurn+ClosingTail.

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingMeta: some View {
        if !bubble.streaming {
            if SignatureLine.shouldDisplay(provider: bubble.provider, model: bubble.model) {
                SignatureLine(
                    provider: bubble.provider, model: bubble.model,
                    elapsedMs: bubble.elapsedMs, reduceMotion: reduceMotion)
            }
            FeedbackRow(active: bubble.feedbackAction, reduceMotion: reduceMotion, onFeedback: onFeedback)
        }
    }
}
