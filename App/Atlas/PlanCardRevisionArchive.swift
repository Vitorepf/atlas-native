import SwiftUI
import AtlasCore

// WAVE-173 density peel

// MARK: - Archive chrome
extension PlanRevisionCompare {
    func revisionArchiveHeader(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        HStack(spacing: 6) {
            Text("v\(rev.revision) arquivado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let iteration = rev.iteration {
                Text("iter \(iteration)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        revisionArchiveWhen(rev)
        revisionArchiveSteps(rev)
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveReason(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let reason = rev.reason, !reason.isEmpty {
            Text(rev.humanReason)
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

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

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveSteps(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if !rev.stepTitles.isEmpty {
            Text(rev.stepTitles.joined(separator: " · "))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveWhen(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let archivedAt = rev.archivedAt {
            Text(editorialArchivedAt(archivedAt))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
