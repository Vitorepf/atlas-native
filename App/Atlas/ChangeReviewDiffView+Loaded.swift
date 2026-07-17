import SwiftUI
import AtlasCore

// Loaded diff — peel de ChangeReviewDiffView+Body.
// Scroll → ChangeReviewDiffView+Loaded+DiffScroll.swift
// Warnings → ChangeReviewDiffView+LoadedWarnings.swift

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiff(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            loadedDiffScroll(response)
            loadedDiffWarnings(response)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}
