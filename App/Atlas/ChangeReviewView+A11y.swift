import SwiftUI
import AtlasCore

/// Spoken sheet label — peel de ChangeReviewSheet (CICLO C residual honesty).
/// Load → ChangeReviewView+A11y+Load.swift
/// Available → ChangeReviewView+A11y+Available.swift

extension ChangeReviewSheet {
    func spokenReviewSheetLabel() -> String {
        if let load = spokenReviewSheetLoadLabel() { return load }
        guard let review else { return "revisão de mudanças" }
        return spokenReviewSheetAvailableLabel(review)
    }

    static let reviewSheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"
}
