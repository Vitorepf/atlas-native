import SwiftUI
import AtlasCore

// H3+ heading — peel de AtlasMarkdownView+Rendering.

extension AtlasMarkdownView {
    func headingDefault(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: .system(size: 14, weight: .semibold), size: 14, color: AtlasTheme.textPrimary)))
            .padding(.top, 2)
    }
}
