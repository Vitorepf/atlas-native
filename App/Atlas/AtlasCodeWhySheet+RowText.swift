import SwiftUI
import AtlasCore

// Why row text stack — peel de AtlasCodeWhySheet+Rows.

extension AtlasCodeWhySheet {
    func whyRowText(_ commit: AtlasCodeWhy.Commit, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
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
            Text(meta(for: commit))
                .font(AtlasFont.mono(10.5))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(commit.subject)
                .font(.system(size: 11))
                .foregroundStyle(AtlasTheme.textSecondary.opacity(0.75))
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        .padding(.bottom, isLast ? 0 : 18)
    }
}
