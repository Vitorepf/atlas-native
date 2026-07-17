import SwiftUI
import AtlasCore

// Accept action — peel de ChangeReviewRunActions+Buttons.

extension ChangeReviewRunActions {
    func performAccept() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
    }
}
