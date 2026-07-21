import AtlasCore
import SwiftUI

// Cycle 041 fuse → ChangeReviewRunActions+Reject.swift

extension ChangeReviewRunActions {
    func rejectReviewAction() {
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                rejectReviewAction()
            } label: {
                rejectButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("rejeitar revisão inteira")
            .accessibilityHint("rejeita o run de engenharia desta execução")
            .accessibilityIdentifier(A11yID.reviewRunReject)
        }
    }
}

extension ChangeReviewRunActions {
    var rejectButtonLabel: some View {
        Text("Rejeitar")
            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
    }
}
