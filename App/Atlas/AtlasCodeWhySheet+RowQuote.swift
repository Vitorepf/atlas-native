import SwiftUI
import AtlasCore

// Why row quote — peel de AtlasCodeWhySheet+RowText.

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyRowQuote(_ commit: AtlasCodeWhy.Commit) -> some View {
        if let quote = commit.provenance?.quote {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        } else {
            Text("sem proveniência registrada")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
