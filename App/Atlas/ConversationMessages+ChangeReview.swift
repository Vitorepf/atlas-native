import SwiftUI
import AtlasCore

// Change-review chip — peel de ConversationMessages (régua ≤100).

extension ConversationMessages {
    @ViewBuilder
    func changeReviewChip(for bubble: ChatBubble) -> some View {
        if bubble.role == "assistant", !bubble.streaming,
           let trace = bubble.traceId,
           let review = model.reviews.changeReviewsByTrace[trace],
           review.state == .available,
           ChangeReviewSheet.hasReviewSurface(review) {
            Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.forwardslash.minus").font(.system(size: 11))
                    Text("Revisar mudanças").font(.system(.footnote, weight: .medium))
                }
                .foregroundStyle(AtlasTheme.textSecondary)
                .padding(.horizontal, 13).padding(.vertical, 7)
                .background(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
            }
            .buttonStyle(PressableScale())
            .accessibilityHint("abre arquivos, diff e provas desta execução")
        }
    }
}
