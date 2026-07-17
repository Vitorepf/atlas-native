import SwiftUI
import AtlasCore

// MARK: - Arena suite rows (peel de ArenaSuitesSection)
// Sparkline → ArenaSuiteSparkline.swift

struct ArenaSuiteRow: View {
    let suite: AtlasArenaSuite

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(suite.suite.uppercased())
                        .font(AtlasFont.mono(12))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                    if !suite.adapterInstalled {
                        Text("sem adapter")
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                    if suite.hasRegression {
                        Circle().fill(AtlasTheme.alert).frame(width: 7, height: 7)
                            .accessibilityHidden(true)
                    }
                }
                Text(subtitle)
                    .font(.system(.caption))
                    .foregroundStyle(suite.isMeasured ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 8)
            if let engine = suite.engines.first,
               ArenaSuitesSectionA11y.hasSparkline(for: suite) {
                SuiteSparkline(engine: engine).frame(width: 64, height: 30)
            } else if suite.isMeasured {
                Text("medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityHidden(true)
    }

    private var subtitle: String {
        suite.arenaSubtitleText
    }
}
