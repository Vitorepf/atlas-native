import AtlasCore
import Foundation

// Cycle 045 fuse → ChangeReviewPatchA11yCard.swift

extension ChangeReviewPatchA11yCard {
    static func spokenDiffState(expanded: Bool) -> String {
        expanded ? "diff expandido" : "diff recolhido"
    }
}

extension ChangeReviewPatchA11yCard {
    static func spokenFileCounts(changed: Int, created: Int, deleted: Int) -> String? {
        let total = changed + created + deleted
        guard total > 0 else { return nil }
        var fileParts: [String] = []
        if changed > 0 { fileParts.append("\(changed) alterado\(changed == 1 ? "" : "s")") }
        if created > 0 { fileParts.append("\(created) novo\(created == 1 ? "" : "s")") }
        if deleted > 0 { fileParts.append("\(deleted) removido\(deleted == 1 ? "" : "s")") }
        return fileParts.joined(separator: ", ")
    }
}

extension ChangeReviewPatchA11yCard {
    static func spokenRiskFlags(_ flags: [String]) -> String? {
        guard !flags.isEmpty else { return nil }
        return "alertas \(flags.joined(separator: ", "))"
    }
}
