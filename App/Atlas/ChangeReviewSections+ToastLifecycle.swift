import SwiftUI
import AtlasCore

// Toast auto-dismiss — peel de ChangeReviewSections+Toast.

extension ChangeReviewToast {
    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        if reduceMotion { reviews.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
    }
}
