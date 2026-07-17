import SwiftUI
import AtlasCore

// Meta do lead (índice + papel + snippet) — peel de ConversationChromeSheets+OutlineLead.
// Index → ConversationChromeSheets+OutlineLeadMeta+Index.swift
// Snippet → ConversationChromeSheets+OutlineLeadMeta+Snippet.swift

extension ConversationOutlineRow {
    var outlineLeadMeta: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            outlineLeadIndex
            outlineLeadSnippetStack
            Spacer(minLength: 0)
        }
    }
}
