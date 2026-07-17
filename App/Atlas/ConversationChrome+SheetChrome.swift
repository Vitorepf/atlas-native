import SwiftUI
import AtlasCore

// Sheet shell chrome — peel de ConversationChrome.

extension SheetShell {
    var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
            .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            .accessibilityHidden(true)
    }

    var sheetTitle: some View {
        Text(title)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.bottom, 14)
            .accessibilityAddTraits(.isHeader)
    }
}
