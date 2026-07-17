import SwiftUI
import AtlasCore

/// Aceitar o run = aceitar todos os arquivos capturados e depois o run —
/// semântica do servidor; o botão só existe se a ação estiver disponível.
struct ChangeReviewRunActions: View {
    let review: AtlasTraceChangeReview
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Binding var applying: Bool

    var body: some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            HStack(spacing: 10) {
                if available.contains(.accept) {
                    Button {
                        applying = true
                        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
                    } label: {
                        Text("Aceitar tudo")
                            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.accent))
                    }
                }
                if available.contains(.reject) {
                    Button {
                        applying = true
                        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
                    } label: {
                        Text("Rejeitar")
                            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
                            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
                    }
                }
                if applying { ProgressView().tint(AtlasTheme.accent) }
            }
            .disabled(applying)
            .padding(.top, 4)
        }
    }
}
