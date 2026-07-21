import AtlasCore
import SwiftUI

// Cycle 041 fuse → ChangeReviewFindingsSection+Axis.swift

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

extension ChangeReviewFindingsSection {
    func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}

extension ChangeReviewFindingsSection {
    var groups: [String: [AtlasTraceChangeReview.Finding]] {
        Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
    }
}
