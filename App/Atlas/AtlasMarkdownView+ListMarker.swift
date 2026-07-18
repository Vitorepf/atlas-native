import SwiftUI
import AtlasCore

// List item marker — peel de AtlasMarkdownView+Blocks.

extension AtlasMarkdownView {
    @ViewBuilder
    func listItemMarker(ordered: Bool, index: Int) -> some View {
        if ordered {
            Text("\(index + 1).")
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 26, alignment: .leading).padding(.top, 3)
                .accessibilityHidden(true)
        } else {
            Text("—")
                .atlasSans(16).foregroundStyle(AtlasTheme.accent)
                .frame(width: 22, alignment: .leading)
                .accessibilityHidden(true)
        }
    }
}
