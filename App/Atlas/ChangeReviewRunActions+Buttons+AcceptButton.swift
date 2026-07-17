import SwiftUI
import AtlasCore

// Accept button chrome — peel de ChangeReviewRunActions+Buttons.

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
