import SwiftUI
import AtlasCore

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// Conteúdo: ChangeReviewView+Content · spoken: +A11y · available: +Available.
// Toolbar → ChangeReviewView+Toolbar.swift
// Load → ChangeReviewView+Load.swift
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
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("Revisar mudanças")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { reviewToolbar }
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews, reduceMotion: reduceMotion) }
            .accessibilityIdentifier(A11yID.reviewSheet)
            .accessibilityLabel(spokenReviewSheetLabel())
            .accessibilityHint(Self.reviewSheetHint)
        }
        .task { await refreshReviewTask() }
    }
}
