import SwiftUI
import AtlasCore

// Reject action — peel de ChangeReviewRunActions+Reject.

extension ChangeReviewRunActions {
    func rejectReviewAction() {
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
    }
}
