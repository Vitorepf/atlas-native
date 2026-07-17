import SwiftUI
import AtlasCore

// Tabelas — peel de AtlasMarkdownView+Rendering.

extension AtlasMarkdownView {
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
