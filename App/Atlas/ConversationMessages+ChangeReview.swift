import AtlasCore
import SwiftUI

// Cycle 029 fuse → ConversationMessages+ChangeReview.swift

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChipButton(for bubble: ChatBubble, trace: TraceID) -> some View {
        Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
            changeReviewChipLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(
            ConversationMessagesA11y.spokenChangeReview(
                patchCount: model.reviews.changeReviewsByTrace[trace]!.patches.count
            )
        )
        .accessibilityHint(ConversationMessagesA11y.changeReviewHint)
        .accessibilityIdentifier(A11yID.reviewChip(trace.rawValue))
    }
}

extension ConversationMessages {
    func showsChangeReviewChip(for bubble: ChatBubble) -> Bool {
        bubble.role == "assistant"
            && !bubble.streaming
            && bubble.traceId != nil
            && model.reviews.changeReviewsByTrace[bubble.traceId!]?.state == .available
            && ChangeReviewSheet.hasReviewSurface(
                model.reviews.changeReviewsByTrace[bubble.traceId!]!
            )
    }
}

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if showsChangeReviewChip(for: bubble), let trace = bubble.traceId {
            changeReviewChipButton(for: bubble, trace: trace)
        }
    }
}

extension ConversationMessages {
    var changeReviewChipLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.forwardslash.minus").atlasSans(11)
            Text("Revisar mudanças").font(.system(.footnote, weight: .medium))
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 13).padding(.vertical, 7)
        .background(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
