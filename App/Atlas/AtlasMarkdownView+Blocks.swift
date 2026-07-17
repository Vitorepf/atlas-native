import SwiftUI
import AtlasCore

// List + quote blocks — peel de AtlasMarkdownView.
// Marcadores tipográficos (— / números / barra) são decorativos; VoiceOver lê conteúdo.

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlock(ordered: Bool, items: [[InlineSpan]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .top, spacing: 0) {
                    if ordered {
                        Text("\(idx + 1).")
                            .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textSecondary)
                            .frame(width: 26, alignment: .leading).padding(.top, 3)
                            .accessibilityHidden(true)
                    } else {
                        Text("—")
                            .font(.system(size: 16)).foregroundStyle(AtlasTheme.accent)
                            .frame(width: 22, alignment: .leading)
                            .accessibilityHidden(true)
                    }
                    Text(inline(item, base: .init(font: .system(size: 16), size: 16, color: AtlasTheme.textPrimary)))
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(MarkdownBlocksA11y.spokenListItem(ordered: ordered, index: idx, plain: plain(item)))
            }
        }
    }

    @ViewBuilder
    func quoteBlock(_ spans: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                .accessibilityHidden(true)
            Text(inline(spans, base: .init(font: AtlasFont.serifItalic(17), size: 17, color: AtlasTheme.textPrimary)))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenQuote(plain(spans)))
    }
}
