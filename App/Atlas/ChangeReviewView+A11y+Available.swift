import SwiftUI
import AtlasCore

/// Review sheet available spoken — peel de ChangeReviewView+A11y.

extension ChangeReviewSheet {
    func spokenReviewSheetAvailableLabel(_ review: AtlasTraceChangeReview) -> String {
        switch review.state {
        case .available:
            if Self.hasReviewSurface(review) {
                let patches = review.patches.count
                return "revisão de mudanças disponível, \(patches) patch\(patches == 1 ? "" : "es")"
            }
            return "revisão de mudanças ligada, sem patches nem provas publicadas"
        case .unavailable:
            return "revisão de mudanças indisponível"
        }
    }
}
