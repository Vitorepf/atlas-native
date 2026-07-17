import SwiftUI
import AtlasCore

// Botão Rejeitar — peel de ChangeReviewRunActions+Buttons.
// Label → ChangeReviewRunActions+Reject+Label.swift
// Action → ChangeReviewRunActions+Reject+Action.swift

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
