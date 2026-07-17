import SwiftUI
import AtlasCore

/// Review available with surface — peel de ChangeReviewView+A11y+Available.

extension ChangeReviewSheet {
    func spokenReviewSheetSurfaceLabel(_ review: AtlasTraceChangeReview) -> String {
        if Self.hasReviewSurface(review) {
            let patches = review.patches.count
            return "revisão de mudanças disponível, \(patches) patch\(patches == 1 ? "" : "es")"
        }
        return "revisão de mudanças ligada, sem patches nem provas publicadas"
    }
}
