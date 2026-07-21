import SwiftUI
import AtlasCore

// User quote block — peel de EditorialTurn+User.

extension EditorialTurn {
    var userQuote: some View {
        Text("\"\(bubble.text)\"")
            .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.leading, 16)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel(EditorialTurnA11y.spokenUserMessage(bubble.text))
    }
}
