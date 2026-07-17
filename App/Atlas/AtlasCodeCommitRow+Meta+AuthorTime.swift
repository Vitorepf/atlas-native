import SwiftUI
import AtlasCore

// Author/time prefix — peel de AtlasCodeCommitRow+Meta.

extension AtlasCodeCommitRow {
    @ViewBuilder
    var commitMetaAuthorTime: some View {
        Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
            .accessibilityHidden(true)
    }
}
