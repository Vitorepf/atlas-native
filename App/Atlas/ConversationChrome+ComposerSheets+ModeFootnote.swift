import SwiftUI

// Mode sheet footnote — peel de ConversationChrome+ComposerSheets.

extension ModeSheet {
    var modeFootnote: some View {
        Text(ComposerSheetA11y.modeFootnote)
            .font(.system(size: 12))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}
