import SwiftUI
import AtlasCore

// Botões Aceitar — peel de ChangeReviewRunActions.
// Applying → ChangeReviewRunActions+Applying.swift
// Reject → ChangeReviewRunActions+Reject.swift
// Label → ChangeReviewRunActions+AcceptLabel.swift

extension ChangeReviewRunActions {
    @ViewBuilder
    func acceptButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.accept) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                applying = true
                Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
            } label: {
                acceptButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("aceitar todos os arquivos e concluir revisão")
            .accessibilityHint("aceita cada arquivo capturado e depois conclui o run")
            .accessibilityIdentifier(A11yID.reviewRunAccept)
        }
    }
}
