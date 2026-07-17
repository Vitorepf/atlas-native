import SwiftUI
import UIKit

// Mode rows — peel de ConversationChrome+ComposerSheets.

extension ModeSheet {
    var modeRows: some View {
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
}
