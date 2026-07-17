import SwiftUI
import AtlasCore

// C19 / cena 02 — "comparar versões" só com planRevisions tipados.
// Extraído do PlanCard para manter o shell sob a régua (~200).
// Compare → PlanCard+RevisionsCompare.swift

struct PlanRevisionCompare: View {
    let plan: AtlasExecutionPlan
    let revisions: [AtlasTraceGovernance.PlanRevision]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            comparisonBody
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
