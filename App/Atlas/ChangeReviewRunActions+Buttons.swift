import SwiftUI
import AtlasCore

// Botões Aceitar — peel de ChangeReviewRunActions.
// Applying → ChangeReviewRunActions+Applying.swift
// Reject → ChangeReviewRunActions+Reject.swift

extension ChangeReviewRunActions {
    @ViewBuilder
    func acceptButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.accept) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                applying = true
                Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
            } label: {
                Text("Aceitar tudo")
                    .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Capsule().fill(AtlasTheme.accent))
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("aceitar todos os arquivos e concluir revisão")
            .accessibilityHint("aceita cada arquivo capturado e depois conclui o run")
            .accessibilityIdentifier(A11yID.reviewRunAccept)
        }
    }
}
