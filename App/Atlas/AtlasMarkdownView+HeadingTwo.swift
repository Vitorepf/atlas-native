import SwiftUI
import AtlasCore

// H2 heading — peel de AtlasMarkdownView+Rendering.

extension AtlasMarkdownView {
    func headingTwo(_ spans: [InlineSpan]) -> some View {
        Text(plain(spans).uppercased())
            .font(.system(size: 11, weight: .medium)).tracking(1.1)
            .foregroundStyle(AtlasTheme.textSecondary)
            .padding(.top, 6).padding(.bottom, 2)
    }
}
