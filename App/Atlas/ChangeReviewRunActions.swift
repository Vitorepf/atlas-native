import AtlasCore
import SwiftUI

// Cycle 040 fuse → ChangeReviewRunActions.swift

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
