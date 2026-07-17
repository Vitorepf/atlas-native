import SwiftUI
import AtlasCore

// Linha de arquivo de revisão — peel de PlanCard+RevisionHelpers.
// Meta → PlanCard+RevisionArchiveMeta.swift

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
            revisionArchiveMeta(rev)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }
}
