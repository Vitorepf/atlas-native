import SwiftUI
import AtlasCore

// Archive meta lines — peel de PlanCard+RevisionArchiveRow.

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let reason = rev.reason, !reason.isEmpty {
            Text(rev.humanReason)
                .font(.system(size: 12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        if let archivedAt = rev.archivedAt {
            Text(editorialArchivedAt(archivedAt))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        if !rev.stepTitles.isEmpty {
            Text(rev.stepTitles.joined(separator: " · "))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
