import SwiftUI
import AtlasCore

// Entered steps list — peel de PlanCard+RevisionsCompare.

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonEnteredList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.entered.isEmpty {
            revisionList(label: "entraram", items: comparison.entered, tone: .added)
        }
    }
}
