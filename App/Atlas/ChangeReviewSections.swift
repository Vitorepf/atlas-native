import SwiftUI
import AtlasCore

// MARK: - Seções remanescentes da ChangeReviewSheet (C15 · C16)
// Diff → ChangeReviewDiffSection · Conselho → ChangeReviewCouncilSection.
// Checks → ChangeReviewSections+Checks.swift
// Chrome → ChangeReviewSections+RunChrome.swift
// Fields → ChangeReviewSections+RunFields.swift

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }
}
