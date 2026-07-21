import SwiftUI
import AtlasCore

// Tabelas — peel de AtlasMarkdownView+Rendering.
// Header → AtlasMarkdownView+TableHeader.swift
// DataRows → AtlasMarkdownView+Table+DataRows.swift

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
