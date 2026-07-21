import SwiftUI
import AtlasCore

// Axis group — peel de ChangeReviewFindingsSection.
// Label → ChangeReviewFindingsSection+AxisLabel.swift
// Header → ChangeReviewFindingsSection+AxisHeader.swift

extension ChangeReviewFindingsSection {
    func axisGroup(axis: String, axisFindings: [AtlasTraceChangeReview.Finding]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            axisHeaderRow(axis: axis, count: axisFindings.count)
            ForEach(axisFindings) { f in
                ChangeReviewFindingRow(finding: f)
            }
        }
    }
}
