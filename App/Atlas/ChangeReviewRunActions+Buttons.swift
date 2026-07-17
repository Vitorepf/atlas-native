import SwiftUI
import AtlasCore

// Botões Aceitar/Rejeitar — peel de ChangeReviewRunActions.

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

    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                applying = true
                Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
            } label: {
                Text("Rejeitar")
                    .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
                    .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("rejeitar revisão inteira")
            .accessibilityHint("rejeita o run de engenharia desta execução")
            .accessibilityIdentifier(A11yID.reviewRunReject)
        }
    }

    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            Text("registrando…")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("registrando decisão")
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel("registrando decisão")
        }
    }
}
