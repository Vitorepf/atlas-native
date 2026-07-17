import SwiftUI
import AtlasCore

// Lead icon + filename — peel de AtlasCodeFileRow.

extension AtlasCodeFileRow {
    var lead: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 8.5, weight: .bold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 17, height: 17)
                .background(AtlasTheme.surfaceHi, in: RoundedRectangle(cornerRadius: 5))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(file.fileName)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let subtitle {
                    Text(subtitle)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }
            .accessibilityHidden(true)

            Spacer(minLength: 8)

            diffStats
        }
    }
}
