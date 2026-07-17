import SwiftUI
import AtlasCore

// Why row text stack — peel de AtlasCodeWhySheet+Rows.
// Quote → AtlasCodeWhySheet+RowQuote.swift

extension AtlasCodeWhySheet {
    func whyRowText(_ commit: AtlasCodeWhy.Commit, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            whyRowQuote(commit)
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
