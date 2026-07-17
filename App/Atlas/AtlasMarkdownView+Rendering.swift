import SwiftUI
import AtlasCore

// Headings + tabelas — peel de AtlasMarkdownView (régua anti-inchaço).
// Inline/plain → AtlasMarkdownView+Inline.swift

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

    func tableView(_ headers: [[InlineSpan]], _ rows: [[[InlineSpan]]]) -> some View {
        let colCount = max(headers.count, rows.map { $0.count }.max() ?? 0)
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<colCount, id: \.self) { ci in
                    Text(plain(ci < headers.count ? headers[ci] : []).uppercased())
                        .font(AtlasFont.mono(10, .medium)).tracking(1.4)
                        .foregroundStyle(AtlasTheme.accent)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
                }
            }
            .padding(.vertical, 10)
            .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.separator).frame(height: 1) }

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(0..<colCount, id: \.self) { ci in
                        Text(inline(ci < row.count ? row[ci] : [], base: .init(font: .system(size: 14), size: 14, color: AtlasTheme.textPrimary)))
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1) }
            }
        }
        .overlay(alignment: .top) { Rectangle().fill(AtlasTheme.separator).frame(height: 1) }
    }
}
