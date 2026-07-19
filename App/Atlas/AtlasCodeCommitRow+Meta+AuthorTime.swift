import SwiftUI
import AtlasCore

// Meta lead/time — peel de AtlasCodeCommitRow+Meta.
// Lidera pelo TIPO do commit (sinal alto); autor só quando não-convencional.

extension AtlasCodeCommitRow {
    @ViewBuilder
    var commitMetaAuthorTime: some View {
        Text(metaLead)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
            .accessibilityHidden(true)
    }
}
