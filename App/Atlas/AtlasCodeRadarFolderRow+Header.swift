import SwiftUI
import AtlasCore

/// Cabeçalho da pasta — peel de AtlasCodeFolderRow (régua ≤100).
/// Badge → AtlasCodeRadarFolderRow+Badge.swift
/// Title → AtlasCodeRadarFolderRow+HeaderTitle.swift
/// Chevron → AtlasCodeRadarFolderRow+HeaderChevron.swift

extension AtlasCodeFolderRow {
    var folderHeaderLabel: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            folderTitleStack
            Spacer(minLength: 6)
            exceptionBadge
            folderHeaderChevron
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
