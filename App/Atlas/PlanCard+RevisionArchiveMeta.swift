import SwiftUI
import AtlasCore

// Archive meta lines — peel de PlanCard+RevisionArchiveRow.
// Steps → PlanCard+RevisionArchiveSteps.swift
// Reason → PlanCard+RevisionArchiveReason.swift
// When → PlanCard+RevisionArchiveWhen.swift

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        revisionArchiveWhen(rev)
        revisionArchiveSteps(rev)
    }
}
