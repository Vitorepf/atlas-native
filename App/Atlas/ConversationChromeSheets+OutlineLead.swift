import SwiftUI
import AtlasCore

// Snippet + lead — peel de ConversationOutlineRow.
// Meta → ConversationChromeSheets+OutlineLeadMeta.swift

extension ConversationOutlineRow {
    var snippet: String {
        ConversationOutlineA11y.spokenSnippet(from: bubble.text)
    }

    var outlineLead: some View {
        outlineLeadMeta
    }
}
