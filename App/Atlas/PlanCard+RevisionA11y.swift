import SwiftUI
import AtlasCore

// A11y — peel de PlanCard+RevisionHelpers.
// Compare → PlanCard+RevisionCompare.swift
// Archive → PlanCard+RevisionArchiveA11y.swift

extension PlanRevisionCompare {
    func comparisonAccessibilityLabel(_ comparison: RevisionComparison) -> String {
        var parts = ["comparação do plano, versão \(comparison.revision.revision) arquivada"]
        if !comparison.left.isEmpty {
            parts.append("\(comparison.left.count) passos saíram")
        }
        if !comparison.entered.isEmpty {
            parts.append("\(comparison.entered.count) passos entraram")
        }
        return parts.joined(separator: ", ")
    }
}
