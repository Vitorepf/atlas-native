import SwiftUI
import AtlasCore

/// Cabeçalho da pasta — peel de AtlasCodeFolderRow (régua ≤100).

extension AtlasCodeFolderRow {
    var folderHeaderLabel: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(folder.name)
                    .font(AtlasFont.serif(16, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios")
                    .font(.system(size: 11.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .accessibilityHidden(true)
            Spacer(minLength: 6)
            if verifiedExceptionCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(verifiedExceptionCount)")
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                }
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
