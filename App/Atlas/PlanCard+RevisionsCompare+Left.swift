import SwiftUI
import AtlasCore

// Removed steps list — peel de PlanCard+RevisionsCompare.

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonLeftList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.left.isEmpty {
            revisionList(label: "saíram", items: comparison.left, tone: .removed)
        }
    }
}
