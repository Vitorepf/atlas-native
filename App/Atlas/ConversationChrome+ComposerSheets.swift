import SwiftUI
import UIKit

// Seletor de modo do composer — peel de ConversationChrome+ComposerSheets.
// Modes → ConversationChrome+ComposerSheets+Modes.swift
// Rows → ConversationChrome+ComposerSheets+ModeRows.swift

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        SheetShell(title: "Modo") {
            Text(ComposerSheetA11y.modeFootnote)
                .font(.system(size: 12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityHidden(true)
            modeRows
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel("modo da conversa")
        .accessibilityHint(ComposerSheetA11y.modeSheetHint)
    }
}
