import SwiftUI
import AtlasCore

// Helpers de revisão — peel de PlanCard+Revisions.
// Archive row → PlanCard+RevisionArchiveRow.swift · List → PlanCard+RevisionList.swift

extension PlanRevisionCompare {
    enum RevisionTone { case removed, added }

    func hasArchiveMetadata(_ rev: AtlasTraceGovernance.PlanRevision) -> Bool {
        rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
    }

    func editorialArchivedAt(_ raw: String) -> String {
        if let tIndex = raw.firstIndex(of: "T") {
            return String(raw[..<tIndex])
        }
        return raw
    }
}
