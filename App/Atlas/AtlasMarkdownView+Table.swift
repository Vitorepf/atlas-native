import SwiftUI
import AtlasCore

// Cycle 022 fuse → AtlasMarkdownView+Table.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func tableDataRows(_ rows: [[[InlineSpan]]], colCount: Int) -> some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
            HStack(spacing: 0) {
                ForEach(0..<colCount, id: \.self) { ci in
                    Text(inline(ci < row.count ? row[ci] : [], base: .init(font: AtlasFont.sans(14, weight: .regular, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
                }
            }
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1) }
        }
    }
}

extension AtlasMarkdownView {
    func tableView(_ headers: [[InlineSpan]], _ rows: [[[InlineSpan]]]) -> some View {
        let colCount = max(headers.count, rows.map { $0.count }.max() ?? 0)
        return VStack(spacing: 0) {
            tableHeaderRow(headers, colCount: colCount)
            tableDataRows(rows, colCount: colCount)
        }
        .overlay(alignment: .top) { Rectangle().fill(AtlasTheme.separator).frame(height: 1) }
    }
}

extension AtlasMarkdownView {
    func tableHeaderRow(_ headers: [[InlineSpan]], colCount: Int) -> some View {
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
    }
}
