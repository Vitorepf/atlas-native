import SwiftUI
import AtlasCore

// Diff loaded/unavailable — peel de ChangeReviewDiffView.
// Loaded → ChangeReviewDiffView+Loaded.swift
// Loading → ChangeReviewDiffView+Body+Loading.swift
// Unavailable → ChangeReviewDiffView+Body+Unavailable.swift

extension ChangeReviewDiffView {
    @ViewBuilder
    func diffBody(response: AtlasTraceChangeReviewDiffResponse?) -> some View {
        if let response {
            loadedDiff(response)
        } else if !loadSettled {
            diffBodyLoading
        } else {
            diffBodyUnavailable
        }
    }
}
