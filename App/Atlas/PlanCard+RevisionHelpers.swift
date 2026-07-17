import SwiftUI
import AtlasCore

// Arquivo e comparação de revisões — peel de PlanCard+Revisions.
// List → PlanCard+RevisionList.swift

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
