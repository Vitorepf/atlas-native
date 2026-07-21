import SwiftUI
import AtlasCore

// Outline lead role — peel de ConversationChromeSheets+OutlineLeadMeta.

extension ConversationOutlineRow {
    var outlineLeadRole: some View {
        Text(bubble.role == "user" ? "Você" : "Atlas")
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}
