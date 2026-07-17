import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de WorkspaceRow.
// Trailing → RootChrome+WorkspaceRow+Trailing.swift
// Detail → RootChrome+WorkspaceRow+Detail.swift

extension WorkspaceRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    .accessibilityHidden(true)
                rowDetail
            }
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}
