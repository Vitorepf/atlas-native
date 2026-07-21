import SwiftUI
import AtlasCore

// Snippet stack — peel de ConversationChromeSheets+OutlineLeadMeta.

extension ConversationOutlineRow {
    var outlineLeadSnippetStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            outlineLeadRole
            Text(snippet)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
