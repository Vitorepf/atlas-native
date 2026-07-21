import SwiftUI
import AtlasCore

// Separators entre repos — peel de AtlasCodeRadarFolderRow+Expanded.

extension AtlasCodeFolderRow {
    @ViewBuilder
    func expandedRepoSeparator(after repo: AtlasCodeRepoRef) -> some View {
        if repo.id != folder.repos.last?.id {
            Rectangle()
                .fill(AtlasTheme.separator.opacity(0.4))
                .frame(height: 0.5)
                .padding(.leading, 32)
                .accessibilityHidden(true)
        }
    }
}
