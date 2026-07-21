import SwiftUI
import AtlasCore

// Archive rows — peel de PlanCard+Revisions.

extension PlanRevisionCompare {
    @ViewBuilder
    var revisionArchiveList: some View {
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
