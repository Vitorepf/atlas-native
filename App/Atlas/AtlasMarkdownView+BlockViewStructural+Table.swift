import SwiftUI
import AtlasCore

// Table block — peel de AtlasMarkdownView+BlockViewStructural.

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewTableBlock(_ block: MarkdownBlock) -> some View {
        if case .table(let headers, let rows) = block {
            tableView(headers, rows)
        }
    }
}
