import SwiftUI
import AtlasCore

// Header title block — peel de AtlasCodeWhySheet+Header.

extension AtlasCodeWhySheet {
    var whyHeaderTitleBlock: some View {
        Group {
            Text("POR QUE ESTE ARQUIVO EXISTE")
                .atlasSans(9, .semibold)
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}
