import SwiftUI
import AtlasCore

// Archive meta lines — peel de PlanCard+RevisionArchiveRow.
// Steps → PlanCard+RevisionArchiveSteps.swift
// Reason → PlanCard+RevisionArchiveReason.swift

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        if let archivedAt = rev.archivedAt {
            Text(editorialArchivedAt(archivedAt))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        revisionArchiveSteps(rev)
    }
}
