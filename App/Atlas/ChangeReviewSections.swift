import AtlasCore
import SwiftUI

// Cycle 039 fuse → ChangeReviewSections.swift

// MARK: - Seções remanescentes da ChangeReviewSheet (C15 · C16)

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }
}
