import SwiftUI
import AtlasCore

// Meta do lead (índice + papel + snippet) — peel de ConversationChromeSheets+OutlineLead.

extension ConversationOutlineRow {
    var outlineLeadMeta: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(String(format: "%02d", index))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(bubble.role == "user" ? "Você" : "Atlas")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Text(snippet)
                    .font(.system(.footnote))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}
