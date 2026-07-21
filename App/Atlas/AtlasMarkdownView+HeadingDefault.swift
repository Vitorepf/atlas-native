import SwiftUI
import AtlasCore

// H3+ heading — peel de AtlasMarkdownView+Rendering.

extension AtlasMarkdownView {
    func headingDefault(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.sans(14, weight: .semibold, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 2)
    }
}
