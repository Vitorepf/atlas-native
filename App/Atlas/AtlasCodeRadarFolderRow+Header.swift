import SwiftUI
import AtlasCore

/// Cabeçalho da pasta — peel de AtlasCodeFolderRow (régua ≤100).
/// Leading → AtlasCodeRadarFolderRow+Header+Leading.swift
/// Trailing → AtlasCodeRadarFolderRow+Header+Trailing.swift

extension AtlasCodeFolderRow {
    var folderHeaderLabel: some View {
        HStack(spacing: 12) {
            folderHeaderLeading
            folderHeaderTrailing
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
