import SwiftUI
import AtlasCore

// Clear anchor CTA — peel de AtlasCodeView+AskPill.

extension AtlasCodeView {
    @ViewBuilder
    var askPillClearButton: some View {
        if askModel.isAnchoring {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                askModel.clear()
            } label: {
                Text("mostrar tudo")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AtlasCodeAskPillA11y.clearLabel)
            .accessibilityHint(AtlasCodeAskPillA11y.clearHint)
            .accessibilityIdentifier(A11yID.codeAskClear)
        }
    }
}
