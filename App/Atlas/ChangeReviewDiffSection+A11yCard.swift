import Foundation
import AtlasCore

// Patch card spoken — peel de ChangeReviewDiffSection+A11y.
// Files → ChangeReviewPatchA11yCard+Files.swift · Risk → +Risk.swift

enum ChangeReviewPatchA11yCard {
    static func spokenCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        var parts = ["patch \(String(patch.id.prefix(8)))"]
        if let files = spokenFileCounts(
            changed: patch.changedFiles.count,
            created: patch.createdFiles.count,
            deleted: patch.deletedFiles.count
        ) {
            parts.append(files)
        }
        if let risk = spokenRiskFlags(patch.riskFlags) {
            parts.append(risk)
        }
        parts.append(spokenDiffState(expanded: diffExpanded))
        return parts.joined(separator: ", ")
    }
}
