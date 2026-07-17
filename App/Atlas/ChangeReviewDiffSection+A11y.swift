import Foundation
import AtlasCore

/// Spoken labels do patch/diff — peel de ChangeReviewPatchCard (cena 07 residual honesty).
/// Só contagens e flags publicadas pelo servidor; diff expandido é estado local honesto.
/// Toggle → ChangeReviewDiffSection+A11yToggle.swift
/// Card → ChangeReviewDiffSection+A11yCard.swift

enum ChangeReviewPatchA11y {
    static func spokenCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        ChangeReviewPatchA11yCard.spokenCard(patch: patch, diffExpanded: diffExpanded)
    }

    static func spokenDiffToggle(expanded: Bool) -> String {
        ChangeReviewPatchA11yToggle.spokenDiffToggle(expanded: expanded)
    }

    static func spokenRiskFlags(_ flags: [String]) -> String {
        ChangeReviewPatchA11yToggle.spokenRiskFlags(flags)
    }
}
