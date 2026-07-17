import SwiftUI
import AtlasCore

// Linha de arquivo de revisão — peel de PlanCard+RevisionHelpers.
// Meta → PlanCard+RevisionArchiveMeta.swift
// Header → PlanCard+RevisionArchiveHeader.swift

extension PlanRevisionCompare {
    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            revisionArchiveHeader(rev)
            revisionArchiveMeta(rev)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }
}
