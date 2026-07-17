import SwiftUI
import AtlasCore

// H1 heading — peel de AtlasMarkdownView+Rendering.

extension AtlasMarkdownView {
    func headingOne(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.serif(22, .semibold), size: 22, color: AtlasTheme.textPrimary)))
            .padding(.top, 4)
    }
}
