import SwiftUI
import AtlasCore

// Review load task — peel de ChangeReviewView.

extension ChangeReviewSheet {
    func refreshReviewTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
    }
}
