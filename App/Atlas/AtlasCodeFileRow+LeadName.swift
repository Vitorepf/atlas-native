import SwiftUI
import AtlasCore

// File name stack — peel de AtlasCodeFileRow+Lead.

extension AtlasCodeFileRow {
    var fileNameStack: some View {
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
    }
}
