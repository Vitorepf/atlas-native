import SwiftUI
import AtlasCore

// Findings grouping — peel de ChangeReviewFindingsSection.

extension ChangeReviewFindingsSection {
    var groups: [String: [AtlasTraceChangeReview.Finding]] {
        Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
    }
}
