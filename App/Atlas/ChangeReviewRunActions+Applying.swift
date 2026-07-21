import AtlasCore
import SwiftUI

// Cycle 041 fuse → ChangeReviewRunActions+Applying.swift

extension ChangeReviewRunActions {
    var acceptButtonLabel: some View {
        Text("Aceitar tudo")
            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.accent))
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            applyingStaticLabel
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel("registrando decisão")
        }
    }
}

extension ChangeReviewRunActions {
    var applyingStaticLabel: some View {
        Text("registrando…")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityLabel("registrando decisão")
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func runActionButtonRow(available: [AtlasTraceChangeReview.Action]) -> some View {
        HStack(spacing: 10) {
            acceptButton(available: available)
            rejectButton(available: available)
            if applying { applyingIndicator }
        }
    }
}

extension ChangeReviewRunActions {
    func performAccept() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
    }
}

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
