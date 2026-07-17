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
}
