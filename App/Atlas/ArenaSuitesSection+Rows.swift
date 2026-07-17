import SwiftUI
import AtlasCore

// MARK: - Arena suite rows (peel de ArenaSuitesSection)
// Sparkline → ArenaSuiteSparkline.swift · Trailing → +RowTrailing · Leading → +RowLeading

struct ArenaSuiteRow: View {
    let suite: AtlasArenaSuite

    var body: some View {
        HStack(spacing: 12) {
            suiteLeading
            Spacer(minLength: 8)
            suiteTrailing
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityHidden(true)
    }
}
