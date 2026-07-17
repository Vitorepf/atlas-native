import SwiftUI
import AtlasCore

// C19 / cena 02 — "comparar versões" só com planRevisions tipados.
// Extraído do PlanCard para manter o shell sob a régua (~200).

struct PlanRevisionCompare: View {
    let plan: AtlasExecutionPlan
    let revisions: [AtlasTraceGovernance.PlanRevision]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let comparison = latestComparison, comparison.hasChanges {
                VStack(alignment: .leading, spacing: 7) {
                    Text("v\(comparison.revision.revision) arquivado → plano atual")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    if !comparison.left.isEmpty {
                        revisionList(label: "saíram", items: comparison.left, tone: .removed)
                    }
                    if !comparison.entered.isEmpty {
                        revisionList(label: "entraram", items: comparison.entered, tone: .added)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(comparisonAccessibilityLabel(comparison))
            }
            if revisions.contains(where: hasArchiveMetadata) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(revisions) { rev in
                        if hasArchiveMetadata(rev) {
                            revisionArchiveRow(rev)
                        }
                    }
                }
            }
        }
    }

    private func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
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

    private enum RevisionTone { case removed, added }

    private func revisionList(label: String, items: [String], tone: RevisionTone) -> some View {
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

    private func hasArchiveMetadata(_ rev: AtlasTraceGovernance.PlanRevision) -> Bool {
        rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
    }

    private func editorialArchivedAt(_ raw: String) -> String {
        if let tIndex = raw.firstIndex(of: "T") {
            return String(raw[..<tIndex])
        }
        return raw
    }

    private func comparisonAccessibilityLabel(_ comparison: RevisionComparison) -> String {
        var parts = ["comparação do plano, versão \(comparison.revision.revision) arquivada"]
        if !comparison.left.isEmpty {
            parts.append("\(comparison.left.count) passos saíram")
        }
        if !comparison.entered.isEmpty {
            parts.append("\(comparison.entered.count) passos entraram")
        }
        return parts.joined(separator: ", ")
    }

    private func revisionArchiveAccessibilityLabel(_ rev: AtlasTraceGovernance.PlanRevision) -> String {
        var parts = ["plano versão \(rev.revision) arquivado"]
        if let reason = rev.reason, !reason.isEmpty {
            parts.append(rev.humanReason)
        }
        if let archivedAt = rev.archivedAt {
            parts.append("em \(editorialArchivedAt(archivedAt))")
        }
        if !rev.stepTitles.isEmpty {
            parts.append("\(rev.stepTitles.count) passos")
        }
        return parts.joined(separator: ", ")
    }

    private var latestComparison: RevisionComparison? {
        guard let revision = revisions.last(where: { !$0.stepTitles.isEmpty }) else { return nil }
        let current = plan.steps.map(\.title)
        let archived = revision.stepTitles
        return RevisionComparison(
            revision: revision,
            left: archived.filter { !current.contains($0) },
            entered: current.filter { !archived.contains($0) }
        )
    }

    private struct RevisionComparison {
        let revision: AtlasTraceGovernance.PlanRevision
        let left: [String]
        let entered: [String]
        var hasChanges: Bool { !left.isEmpty || !entered.isEmpty }
    }
}
