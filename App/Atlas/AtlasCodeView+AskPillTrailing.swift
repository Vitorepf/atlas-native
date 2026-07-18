import SwiftUI

// Ask pill trailing chevron — peel de AtlasCodeView+AskPillLeading.

extension AtlasCodeView {
    var askPillTrailingChevron: some View {
        Image(systemName: "chevron.up")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}
