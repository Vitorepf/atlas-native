import SwiftUI
import UIKit

// Seletor de modo do composer — peel de ConversationChrome+ComposerSheets.
// Modes → ConversationChrome+ComposerSheets+Modes.swift
// Rows → ConversationChrome+ComposerSheets+ModeRows.swift
// Footnote → ConversationChrome+ComposerSheets+ModeFootnote.swift

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        SheetShell(title: "Modo") {
            modeFootnote
            modeRows
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel("modo da conversa")
        .accessibilityHint(ComposerSheetA11y.modeSheetHint)
    }
}
