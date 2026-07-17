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
                    Text("plano v\(comparison.revision.revision) arquivado → atual")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    if !comparison.left.isEmpty {
                        revisionList(label: "saíram", items: comparison.left)
                    }
                    if !comparison.entered.isEmpty {
                        revisionList(label: "entraram", items: comparison.entered)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(revisions) { rev in
                    revisionArchiveRow(rev)
                }
            }
        }
    }

    private func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text("plano v\(rev.revision) arquivado")
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
            Text(rev.humanReason)
                .font(.system(size: 12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let archivedAt = rev.archivedAt {
                Text(archivedAt)
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
        .accessibilityLabel("plano versão \(rev.revision) arquivado, \(rev.humanReason)")
    }

    private func revisionList(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
        }
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
