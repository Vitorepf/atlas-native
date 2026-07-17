import SwiftUI
import UIKit

// Seletor de modo do composer — peel de ConversationChrome+ComposerSheets.
// Modes → ConversationChrome+ComposerSheets+Modes.swift

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
            ForEach(Self.modes, id: \.0) { key, label in
                let isSelected = key == selected
                SheetRow(
                    label: label,
                    sub: ComposerSheetA11y.modeFootnote,
                    selected: isSelected,
                    accessibilityLabel: ComposerSheetA11y.modeLabel(key, title: label, selected: isSelected),
                    accessibilityIdentifier: A11yID.modeRow(key)
                ) {
                    selected = key
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    dismiss()
                }
            }
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel("modo da conversa")
        .accessibilityHint(ComposerSheetA11y.modeSheetHint)
    }
}
