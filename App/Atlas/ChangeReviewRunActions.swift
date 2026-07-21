import AtlasCore
import SwiftUI

// Cycle 043 fuse → ChangeReviewRunActions.swift

/// Aceitar o run = aceitar todos os arquivos capturados e depois o run —
/// semântica do servidor; o botão só existe se a ação estiver disponível.
struct ChangeReviewRunActions: View {
    let review: AtlasTraceChangeReview
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Binding var applying: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            runActionButtonRow(available: available)
            .disabled(applying)
            .padding(.top, 4)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: applying)
        }
    }
}

extension ChangeReviewRunActions {
    var acceptButtonLabel: some View {
        Text("Aceitar tudo")
            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(Capsule().fill(AtlasTheme.accent))
            .contentShape(Capsule())
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
        // Medium: accept-all is primary governed commit.
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
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
                // Medium: reject-all is primary governed commit (destructive).
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
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
            .frame(minHeight: 44)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
            .contentShape(Capsule())
    }
}
