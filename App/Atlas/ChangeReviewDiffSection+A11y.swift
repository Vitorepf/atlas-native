import Foundation
import AtlasCore

/// Spoken labels do patch/diff — peel de ChangeReviewPatchCard (cena 07 residual honesty).
/// Só contagens e flags publicadas pelo servidor; diff expandido é estado local honesto.

enum ChangeReviewPatchA11y {
    static func spokenCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        var parts = ["patch \(String(patch.id.prefix(8)))"]
        let changed = patch.changedFiles.count
        let created = patch.createdFiles.count
        let deleted = patch.deletedFiles.count
        let total = changed + created + deleted
        if total > 0 {
            var fileParts: [String] = []
            if changed > 0 { fileParts.append("\(changed) alterado\(changed == 1 ? "" : "s")") }
            if created > 0 { fileParts.append("\(created) novo\(created == 1 ? "" : "s")") }
            if deleted > 0 { fileParts.append("\(deleted) removido\(deleted == 1 ? "" : "s")") }
            parts.append(fileParts.joined(separator: ", "))
        }
        if !patch.riskFlags.isEmpty {
            parts.append("alertas \(patch.riskFlags.joined(separator: ", "))")
        }
        parts.append(diffExpanded ? "diff expandido" : "diff recolhido")
        return parts.joined(separator: ", ")
    }

    static func spokenDiffToggle(expanded: Bool) -> String {
        expanded ? "fechar diff do patch" : "ver diff do patch"
    }

    static func spokenRiskFlags(_ flags: [String]) -> String {
        "alertas de risco, \(flags.joined(separator: ", "))"
    }
}
