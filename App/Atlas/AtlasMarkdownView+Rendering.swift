import SwiftUI
import AtlasCore

// Headings — peel de AtlasMarkdownView (régua anti-inchaço).
// Inline/plain → AtlasMarkdownView+Inline.swift
// Table → AtlasMarkdownView+Table.swift

extension AtlasMarkdownView {
    struct InlineBase { let font: Font; let size: CGFloat; let color: Color }

    @ViewBuilder
    func heading(_ level: Int, _ spans: [InlineSpan]) -> some View {
        switch level {
        case 1:
            Text(inline(spans, base: .init(font: AtlasFont.serif(22, .semibold), size: 22, color: AtlasTheme.textPrimary)))
                .padding(.top, 4)
        case 2:
            Text(plain(spans).uppercased())
                .font(.system(size: 11, weight: .medium)).tracking(1.1)
                .foregroundStyle(AtlasTheme.textSecondary)
                .padding(.top, 6).padding(.bottom, 2)
        default:
            Text(inline(spans, base: .init(font: .system(size: 14, weight: .semibold), size: 14, color: AtlasTheme.textPrimary)))
                .padding(.top, 2)
        }
    }
}
