import SwiftUI
import AtlasCore

// Outline empty state — peel de ConversationChromeSheets+Outline.

extension ConversationOutlineSheet {
    var outlineEmpty: some View {
        Text("Nenhum turno carregado nesta thread.")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .accessibilityLabel(ConversationOutlineA11y.spokenEmptySheet())
            .accessibilityAddTraits(.isStaticText)
    }
}
