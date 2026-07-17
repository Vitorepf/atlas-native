import SwiftUI
import AtlasCore

// Arquivo e comparação de revisões — peel de PlanCard+Revisions.

extension PlanRevisionCompare {
    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text("v\(rev.revision) arquivado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                if let iteration = rev.iteration {
                    Text("iter \(iteration)")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                Spacer(minLength: 0)
            }
            if let reason = rev.reason, !reason.isEmpty {
                Text(rev.humanReason)
                    .font(.system(size: 12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let archivedAt = rev.archivedAt {
                Text(editorialArchivedAt(archivedAt))
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
            if !rev.stepTitles.isEmpty {
                Text(rev.stepTitles.joined(separator: " · "))
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }

    enum RevisionTone { case removed, added }

    func revisionList(label: String, items: [String], tone: RevisionTone) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 12))
                    .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                    .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
                    .lineLimit(2)
            }
        }
    }

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
