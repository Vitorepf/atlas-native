import AtlasCore
import SwiftUI

// Cycle 039 fuse → ChangeReviewView+A11y.swift

extension ChangeReviewSheet {
    func spokenReviewSheetSurfaceLabel(_ review: AtlasTraceChangeReview) -> String {
        if Self.hasReviewSurface(review) {
            let patches = review.patches.count
            return "revisão de mudanças disponível, \(patches) patch\(patches == 1 ? "" : "es")"
        }
        return "revisão de mudanças ligada, sem patches nem provas publicadas"
    }
}

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

extension ChangeReviewSheet {
    func spokenReviewSheetLoadLabel() -> String? {
        if !loadFinished, review == nil { return "revisão de mudanças, consultando" }
        if loadFinished, review == nil { return "revisão de mudanças, indisponível" }
        return nil
    }
}

extension ChangeReviewSheet {
    func spokenReviewSheetLabel() -> String {
        if let load = spokenReviewSheetLoadLabel() { return load }
        guard let review else { return "revisão de mudanças" }
        return spokenReviewSheetAvailableLabel(review)
    }

    static let reviewSheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"
}
