import SwiftUI
import AtlasCore

// Chevron affordance — peel de AtlasCodeRadarFolderRow+Header.

extension AtlasCodeFolderRow {
    @ViewBuilder
    var folderHeaderChevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .accessibilityHidden(true)
    }
}
