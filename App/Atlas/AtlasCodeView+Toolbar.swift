import SwiftUI
import AtlasCore

// Toolbar repo label — peel de AtlasCodeView.

extension AtlasCodeView {
    var codeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Text(model.repo)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
