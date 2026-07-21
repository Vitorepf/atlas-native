import AtlasCore
import SwiftUI

// Cycle 041 fuse → ChangeReviewView.swift

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// Conteúdo: ChangeReviewView+Content · spoken: +A11y · available: +Available.
struct ChangeReviewSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var expandedDiffPatch: String?
    @State var applying = false
    @State var loadFinished = false

    var review: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }

    var body: some View {
        reviewSheetChrome
            .task { await refreshReviewTask() }
    }
}
