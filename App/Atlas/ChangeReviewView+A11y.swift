import SwiftUI
import AtlasCore

/// Spoken sheet label — peel de ChangeReviewSheet (CICLO C residual honesty).

extension ChangeReviewSheet {
    func spokenReviewSheetLabel() -> String {
        if !loadFinished, review == nil { return "revisão de mudanças, consultando" }
        if loadFinished, review == nil { return "revisão de mudanças, indisponível" }
        guard let review else { return "revisão de mudanças" }
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

    static let reviewSheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"
}
