import SwiftUI

// Ask pill trailing chevron — peel de AtlasCodeView+AskPillLeading.

extension AtlasCodeView {
    var askPillTrailingChevron: some View {
        Image(systemName: "chevron.up")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}
