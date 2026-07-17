import SwiftUI
import AtlasCore

/// Review sheet available spoken — peel de ChangeReviewView+A11y.
/// Surface → ChangeReviewView+A11y+Available+Surface.swift

extension ChangeReviewSheet {
    func spokenReviewSheetAvailableLabel(_ review: AtlasTraceChangeReview) -> String {
        switch review.state {
        case .available:
            return spokenReviewSheetSurfaceLabel(review)
        case .unavailable:
            return "revisão de mudanças indisponível"
        }
    }
}
