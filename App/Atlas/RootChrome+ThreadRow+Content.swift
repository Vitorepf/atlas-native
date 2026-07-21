import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de ThreadRow.
// Trailing → RootChrome+ThreadRow+Trailing.swift
// Lead → RootChrome+ThreadRow+Lead.swift
// Tint → RootChrome+ThreadRow+Tint.swift

extension ThreadRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            rowLead
            Text(thread.title).font(AtlasFont.serif(16)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
    }
}
