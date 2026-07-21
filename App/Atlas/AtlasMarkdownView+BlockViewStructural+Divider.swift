import SwiftUI
import AtlasCore

// Divider block — peel de AtlasMarkdownView+BlockViewStructural.

extension AtlasMarkdownView {
    @ViewBuilder
    var blockViewDividerBlock: some View {
        Rectangle().fill(AtlasTheme.separator).frame(height: 1).padding(.vertical, 2)
    }
}
