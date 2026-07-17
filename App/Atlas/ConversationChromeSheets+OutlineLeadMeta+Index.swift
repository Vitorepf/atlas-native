import SwiftUI
import AtlasCore

// Index column — peel de ConversationChromeSheets+OutlineLeadMeta.

extension ConversationOutlineRow {
    var outlineLeadIndex: some View {
        Text(String(format: "%02d", index))
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.accent)
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}
