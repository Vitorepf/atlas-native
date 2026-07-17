import SwiftUI
import AtlasCore

// Botões Aceitar — peel de ChangeReviewRunActions.
// Applying → ChangeReviewRunActions+Applying.swift
// Reject → ChangeReviewRunActions+Reject.swift
// Label → ChangeReviewRunActions+AcceptLabel.swift
// Action → ChangeReviewRunActions+Buttons+AcceptAction.swift

extension ChangeReviewRunActions {
    @ViewBuilder
    func acceptButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.accept) {
            Button(action: performAccept) {
                acceptButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("aceitar todos os arquivos e concluir revisão")
            .accessibilityHint("aceita cada arquivo capturado e depois conclui o run")
            .accessibilityIdentifier(A11yID.reviewRunAccept)
        }
    }
}
