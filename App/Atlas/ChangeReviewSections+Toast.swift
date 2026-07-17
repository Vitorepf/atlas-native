import SwiftUI
import AtlasCore

// ChangeReview toast — peel de ChangeReviewSections+Chrome.
// Lifecycle → ChangeReviewSections+ToastLifecycle.swift

struct ChangeReviewToast: View {
    let reviews: ChangeReviewModel
    var reduceMotion: Bool = false

    var body: some View {
        if let t = reviews.toast {
            toastCapsule(t)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenToast(t))
                .accessibilityIdentifier(A11yID.reviewToast)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .task { await dismissToastAfterDelay() }
        }
    }
}
