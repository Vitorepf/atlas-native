import SwiftUI
import AtlasCore

// Linha de arquivo de revisão — peel de PlanCard+RevisionHelpers.

extension PlanRevisionCompare {
    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }
}
