import AtlasCore
import SwiftUI

// Cycle 038 fuse → AtlasCodeWhySheet+Header.swift

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

extension AtlasCodeWhySheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            whyHeaderTitleBlock
            headerTruncation
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }
}
